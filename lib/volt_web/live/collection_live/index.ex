defmodule VoltWeb.CollectionLive.Index do
  use VoltWeb, :live_view

  alias Volt.CollectionRepo
  alias Volt.Collection

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :collections, CollectionRepo.all())}
  end

  @impl true
  def handle_params(params, _url, socket) do
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Collections")
    |> assign(:collection, nil)
  end

  @impl true
  def handle_info({VoltWeb.CollectionLive.FormComponent, {:saved, collection}}, socket) do
    {:noreply, stream_insert(socket, :collections, collection)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    collection = CollectionRepo.get_collection!(id)
    {:ok, _} = CollectionRepo.delete_collection(collection)

    {:noreply, stream_delete(socket, :collections, collection)}
  end
end
