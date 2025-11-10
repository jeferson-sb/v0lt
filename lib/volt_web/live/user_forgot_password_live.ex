defmodule VoltWeb.UserForgotPasswordLive do
  use VoltWeb, :live_view

  alias Volt.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-sm w-full p-6 border border-zinc-300 bg-seashell shadow-lg shadow-black/5 rounded-xl">
      <.header class="text-center font-title mb-4">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input
          field={@form[:email]}
          class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          type="email"
          placeholder="Email"
          required
        />
        <:actions>
          <button
            phx-disable-with="Sending..."
            class="w-full mt-2 px-4 py-2 cursor-pointer rounded-2xl text-sm font-medium font-body bg-light_red text-primary-foreground shadow-sm shadow-black/5 disabled:pointer-events-none disabled:opacity-50"
          >
            Send password reset instructions
          </button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
