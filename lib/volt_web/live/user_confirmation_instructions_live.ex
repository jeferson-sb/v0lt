defmodule VoltWeb.UserConfirmationInstructionsLive do
  use VoltWeb, :live_view

  alias Volt.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center font-title mb-4">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input
          field={@form[:email]}
          type="email"
          placeholder="Email"
          class="py-2 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          required
        />
        <:actions>
          <button
            phx-disable-with="Sending..."
            class="px-4 py-2 w-full rounded-2xl text-sm font-medium font-body bg-light_red"
          >
            Resend confirmation instructions
          </button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
