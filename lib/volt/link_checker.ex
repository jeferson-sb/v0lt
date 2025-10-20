defmodule Volt.LinkChecker do
  @moduledoc """
  A GenServer that periodically checks the status of links in collections.

  This process runs in the background and:
  - Checks unchecked links
  - Re-checks stale links (older than 24 hours)
  - Updates link status in the database
  - Uses exponential backoff for failed checks
  """
  use GenServer

  alias Volt.{Repo, Url}
  import Ecto.Query
  require Logger

  # Check every 10 minutes
  @check_interval :timer.minutes(10)
  # Re-check links older than 24 hours
  @stale_threshold_hours 24
  # Maximum retry attempts
  @max_attempts 3
  # Process links in batches
  @batch_size 10

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("LinkChecker started")
    schedule_check()
    {:ok, %{}}
  end

  def handle_info(:check_links, state) do
    check_links()
    schedule_check()
    {:noreply, state}
  end

  def handle_call(:force_check, _from, state) do
    check_links()
    {:reply, :ok, state}
  end

  def handle_call({:check_url, url_id}, _from, state) do
    result = check_single_url(url_id)
    {:reply, result, state}
  end

  @doc """
  Manually force a check of all links (useful for testing or manual triggers)
  """
  def force_check do
    GenServer.call(__MODULE__, :force_check)
  end

  @doc """
  Check a specific URL by ID
  """
  def check_url(url_id) do
    GenServer.call(__MODULE__, {:check_url, url_id})
  end

  defp schedule_check do
    Process.send_after(self(), :check_links, @check_interval)
  end

  defp check_links do
    Logger.info("Starting link check cycle")

    urls_to_check = get_urls_to_check()

    Logger.info("Found #{length(urls_to_check)} links to check")

    urls_to_check
    |> Enum.chunk_every(@batch_size)
    |> Enum.each(fn batch ->
      check_batch(batch)
      # Small delay between batches to avoid overwhelming servers
      Process.sleep(1000)
    end)

    Logger.info("Link check cycle completed")
  end

  defp get_urls_to_check do
    stale_datetime = DateTime.utc_now() |> DateTime.add(-@stale_threshold_hours, :hour)

    Logger.info("Looking for URLs to check. Stale threshold: #{stale_datetime}")

    urls =
      from(u in Url,
        # Unchecked links
        # Stale links that need re-checking
        # Failed links with attempts under max (exponential backoff)
        where:
          u.status == "unchecked" or
            u.last_checked_at < ^stale_datetime or
            (u.status == "error" and u.check_attempts < @max_attempts),
        order_by: [asc: u.last_checked_at],
        # Limit to prevent overwhelming the system
        limit: 100
      )
      |> Repo.all()

    Logger.info("Found #{length(urls)} URLs to check")

    Enum.each(urls, fn url ->
      Logger.info(
        "URL to check: #{url.link} (status: #{url.status}, last_checked: #{url.last_checked_at})"
      )
    end)

    urls
  end

  defp check_batch(urls) do
    # Use Task.async_stream for concurrent checking with backpressure
    urls
    |> Task.async_stream(&check_single_url/1,
      max_concurrency: 3,
      # Slightly longer than our HTTP timeout
      timeout: 15_000,
      on_timeout: :kill_task
    )
    |> Enum.each(fn
      {:ok, result} ->
        Logger.debug("Link check completed: #{inspect(result)}")

      {:exit, reason} ->
        Logger.warning("Link check timed out or failed: #{inspect(reason)}")
    end)
  end

  defp check_single_url(%Url{} = url) do
    check_single_url(url.id)
  end

  defp check_single_url(url_id) when is_integer(url_id) do
    url = Repo.get!(Url, url_id)
    Logger.debug("Checking URL: #{url.link}")

    # Mark as checking
    case update_url_status(url, %{
           status: "checking",
           last_checked_at: DateTime.utc_now()
         }) do
      {:ok, updated_url} ->
        full_url = ensure_protocol(url.link)

        try do
          response =
            Req.head!(full_url,
              max_redirects: 3,
              connect_options: [timeout: 5_000],
              receive_timeout: 8_000,
              retry: false
            )

          status = if response.status in 200..299, do: "live", else: "dead"

          update_url_status(updated_url, %{
            status: status,
            status_code: response.status,
            last_checked_at: DateTime.utc_now(),
            check_attempts: url.check_attempts + 1
          })

          Logger.debug("URL #{url.link} is #{status} (#{response.status})")
          {:ok, status, response.status}
        rescue
          error ->
            Logger.warning("Failed to check URL #{url.link}: #{inspect(error)}")

            update_url_status(updated_url, %{
              status: "error",
              last_checked_at: DateTime.utc_now(),
              check_attempts: url.check_attempts + 1
            })

            {:error, error}
        end

      {:error, changeset} ->
        Logger.warning("Failed to update URL status to 'checking': #{inspect(changeset)}")
        {:error, :update_failed}
    end
  end

  defp ensure_protocol(url) do
    cond do
      String.starts_with?(url, ["http://", "https://"]) -> url
      true -> "https://" <> url
    end
  end

  defp update_url_status(url, attrs) do
    url
    |> Url.status_changeset(attrs)
    |> Repo.update()
  end
end
