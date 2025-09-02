defmodule VoltWeb.UrlLive.Index do
  use VoltWeb, :live_view

  alias Volt.Url
  alias Volt.UrlRepo

  @impl true
  def mount(_params, _session, socket) do
    collections = Volt.CollectionRepo.all() |> Volt.Repo.preload([:urls, :user])
    user_collections = Enum.filter(collections, fn collection -> collection.user_id == socket.assigns.current_user.id end)

    socket =
      socket
      |> assign(:my_collections, user_collections)
      |> assign(:collections, collections)

    {:ok, socket}
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
    |> assign(:page_title, "Collections")
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

  def prepend_url(url) do
    case url |> String.starts_with?(["http://", "https://"]) do
      true -> url
      false -> "https://" <> url
    end
  end
end
