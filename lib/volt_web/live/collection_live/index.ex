defmodule VoltWeb.CollectionLive.Index do
  use VoltWeb, :live_view

  alias Volt.CollectionRepo
  alias Volt.Collection
  alias Volt.Url

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
    socket =
      case params["collection_id"] do
        collection_id -> assign(socket, collection_id: collection_id)
        _ -> socket
      end

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Collection")
    |> assign(:collection, CollectionRepo.get_collection!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Collection")
    |> assign(:collection, %Collection{})
  end

  defp apply_action(socket, :new_url, _params) do
    socket
    |> assign(:page_title, "New URL")
    |> assign(:url, %Url{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Collections")
    |> assign(:collection, nil)
  end

  @impl true
  def handle_info({VoltWeb.CollectionLive.FormComponent, {:saved, collection}}, socket) do
    {:noreply, stream_insert(socket, :collections, collection)}
  end

  def handle_info({VoltWeb.UrlLive.FormComponent, {:saved, url}}, socket) do
    {:noreply, stream_insert(socket, :urls, url)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    collection = CollectionRepo.get_collection!(id)
    {:ok, _} = CollectionRepo.delete_collection(collection)

    {:noreply, stream_delete(socket, :collections, collection)}
  end

  def prepend_url(url) do
    case url |> String.starts_with?(["http://", "https://"]) do
      true -> url
      false -> "https://" <> url
    end
  end
end
