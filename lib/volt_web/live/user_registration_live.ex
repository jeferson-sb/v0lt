defmodule VoltWeb.UserRegistrationLive do
  use VoltWeb, :live_view

  alias Volt.Accounts
  alias Volt.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="max-w-sm w-full p-6 border border-zinc-300 bg-seashell shadow-lg shadow-black/5 rounded-xl">
      <.flash_group flash={@flash} />
      <div class="flex items-center justify-center">
        <h2 class="text-lg font-semibold tracking-tight font-title">Register</h2>
      </div>
      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <div class="flex mt-4">
          <span class="inline-flex items-center px-4 text-sm text-zinc-900 border border-zinc-300 rounded-s-2xl">
            @
          </span>
          <.input
            type="text"
            field={@form[:username]}
            class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-e-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
            id="username"
            placeholder="peanutbutterjelly"
            required
          />
        </div>

        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          required
        />
        <.input
          field={@form[:password]}
          type="password"
          label="Password"
          class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          required
        />

        <:actions>
          <button phx-disable-with="Creating account..." type="submit" class="w-full mt-2 px-4 py-2 cursor-pointer rounded-2xl text-sm font-medium font-body bg-light_red text-primary-foreground shadow-sm shadow-black/5 disabled:pointer-events-none disabled:opacity-50">Create an account</button>
        </:actions>
      </.simple_form>
      <div class="flex flex-col gap-2 items-center">
        <p>or</p>
        <.link href={~p"/users/log_in"}>Log in</.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
