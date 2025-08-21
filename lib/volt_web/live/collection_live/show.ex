defmodule VoltWeb.CollectionLive.Show do
  use VoltWeb, :live_view

  alias Volt.CollectionRepo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:collection, CollectionRepo.get_collection!(id))}
  end

  defp page_title(:show), do: "Show Collection"
  defp page_title(:edit), do: "Edit Collection"
end
