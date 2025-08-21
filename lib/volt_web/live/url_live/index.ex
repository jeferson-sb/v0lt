defmodule VoltWeb.UrlLive.Index do
  use VoltWeb, :live_view

  alias Volt.Url
  alias Volt.UrlRepo

  @impl true
  def mount(_params, _session, socket) do
    collections = Volt.CollectionRepo.all() |> Volt.Repo.preload(:urls)
    {:ok, stream(socket, :urls, collections)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New link")
    |> assign(:url, %Url{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Collection")
    |> assign(:url, nil)
  end

  @impl true
  def handle_info({VoltWeb.UrlLive.FormComponent, {:saved, url}}, socket) do
    {:noreply, stream_insert(socket, :urls, url)}
  end

  @impl true
  def handle_info({VoltWeb.CollectionLive.FormComponent, {:saved, collection}}, socket) do
    {:noreply, stream_insert(socket, :collections, collection)}
  end

  # Some helpers

  def prepend_url(url) do
    case url |> String.starts_with?(["http://", "https://"]) do
      true -> url
      false -> "https://" <> url
    end
  end
end
