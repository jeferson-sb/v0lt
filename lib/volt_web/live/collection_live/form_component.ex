defmodule VoltWeb.CollectionLive.FormComponent do
  use VoltWeb, :live_component

  alias Volt.Collections

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-2 min-w-[300px]">
      <.header>
        {@title}
        <:subtitle>Enter your new collection</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="collection-form"
        class="w-full"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex rounded-lg">
          <.input
            field={@form[:name]}
            type="text"
            label="Name"
            class="flex h-9 w-full rounded-lg border border-zinc-300 bg-background px-3 py-2 text-sm text-foreground shadow-black/5 transition-shadow placeholder:text-muted-foreground/70 focus-visible:border-ring focus-visible:outline-none focus-visible:ring-[2px] ring-zinc-200 focus-visible:ring-ring/20 disabled:cursor-not-allowed disabled:opacity-50 z-10 -ms-px shadow-none"
            placeholder="My Collection"
            required
          />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Collection</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{collection: collection} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Collections.change_collection(collection))
     end)}
  end

  @impl true
  def handle_event("validate", %{"collection" => collection_params}, socket) do
    changeset = Collections.change_collection(socket.assigns.collection, collection_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"collection" => collection_params}, socket) do
    save_collection(socket, socket.assigns.action, collection_params)
  end

  defp save_collection(socket, :edit, collection_params) do
    case Collections.update_collection(socket.assigns.collection, collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_collection(socket, :new, collection_params) do
    collection_params = Map.put(collection_params, "user_id", socket.assigns.current_user.id)

    case Collections.create_collection(collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
