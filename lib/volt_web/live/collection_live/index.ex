defmodule VoltWeb.CollectionLive.Index do
  use VoltWeb, :live_view

  alias Volt.{Collections, Collection}
  alias Volt.Url
  alias Volt.UrlRepo

  @impl true
  def mount(_params, _session, socket) do
    socket = load_collections(socket)
    {:ok, socket}
  end

  defp load_collections(socket) do
    user_id = if socket.assigns.current_user, do: socket.assigns.current_user.id, else: nil
    collections_with_likes = Collections.list_collections_with_likes(user_id)

    # Preload the user association for display purposes
    collections =
      collections_with_likes
      |> Enum.map(& &1.collection)
      |> Volt.Repo.preload([:urls, :user])

    # Rebuild the collections with likes data including the preloaded associations
    collections_with_likes =
      Enum.zip(collections, collections_with_likes)
      |> Enum.map(fn {collection_with_preload, like_data} ->
        Map.put(like_data, :collection, collection_with_preload)
      end)

    user_collections =
      if user_id do
        Enum.filter(collections_with_likes, fn %{collection: collection} ->
          collection.user_id == user_id
        end)
      else
        []
      end

    socket
    |> assign(:my_collections, user_collections)
    |> assign(:collections, collections_with_likes)
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      case params["collection_id"] do
        nil -> socket
        collection_id -> assign(socket, collection_id: collection_id)
      end

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"collection_id" => id}) do
    socket
    |> assign(:page_title, "Edit Collection")
    |> assign(:collection, Collections.get_collection!(id))
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
    {:noreply, stream_insert(socket, :collections, collection, at: -1)}
  end

  def handle_info({VoltWeb.UrlLive.FormComponent, {:saved, url}}, socket) do
    {:noreply, stream_insert(socket, :urls, url, at: -1)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if socket.assigns.current_user do
      collection = Collections.get_collection!(id)
      {:ok, _} = Collections.delete_collection(collection)

      {:noreply, stream_delete(socket, :collections, collection)}
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to delete collections")}
    end
  end

  @impl true
  def handle_event("delete_url", %{"id" => id}, socket) do
    if socket.assigns.current_user do
      url = UrlRepo.get_url!(id)
      {:ok, _} = UrlRepo.delete_url(url)

      {:noreply, stream_delete(socket, :urls, url)}
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to delete URLs")}
    end
  end

  @impl true
  def handle_event("like", %{"collection_id" => collection_id, "user_id" => user_id}, socket) do
    if socket.assigns.current_user do
      case Collections.toggle_like(user_id, collection_id) do
        {:ok, _action} ->
          socket = load_collections(socket)
          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, socket}
      end
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to like collections")}
    end
  end

  @impl true
  def handle_event("pick", %{"id" => id, "color" => color}, socket) do
    if socket.assigns.current_user do
      collection = Collections.get_collection!(id)
      {:ok, _data} = Collections.update_collection(collection, %{color: color})

      socket = load_collections(socket)
      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to change collection colors")}
    end
  end

  def prepend_url(url) do
    case url |> String.starts_with?(["http://", "https://"]) do
      true -> url
      false -> "https://" <> url
    end
  end
end
