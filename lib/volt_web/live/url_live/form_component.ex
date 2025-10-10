defmodule VoltWeb.UrlLive.FormComponent do
  use VoltWeb, :live_component

  alias Volt.UrlRepo

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-2 min-w-[300px]">
      <.header>
        {@title}
        <:subtitle>Enter your new link</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="url-form"
        class="w-full"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <label
          class="text-sm font-medium leading-4 text-foreground peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
          for="link_url"
        >
          Link
        </label>
        <.input
          field={@form[:link]}
          addon="https://"
          id="link_url"
          type="text"
          class="flex h-9 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground shadow-black/5 transition-shadow placeholder:text-muted-foreground/70 focus-visible:border-ring focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/20 disabled:cursor-not-allowed disabled:opacity-50 z-10 -ms-px rounded-s-none shadow-none"
          placeholder="google.com"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Url</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{url: url} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(UrlRepo.change(url))
     end)}
  end

  @impl true
  def handle_event("validate", %{"url" => url_params}, socket) do
    changeset = UrlRepo.change(socket.assigns.url, url_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"url" => url_params}, socket) do
    save_url(socket, socket.assigns.action, url_params)
  end

  defp save_url(socket, :new_url, url_params) do
    url_params = Map.put(url_params, "collection_id", socket.assigns.collection_id)

    case UrlRepo.create(url_params) do
      {:ok, url} ->
        notify_parent({:saved, url})

        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
