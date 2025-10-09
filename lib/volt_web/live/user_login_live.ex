defmodule VoltWeb.UserLoginLive do
  use VoltWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-md w-2/4 p-6 border border-zinc-300 bg-seashell shadow-lg shadow-black/5 rounded-xl">
      <.header class="text-center font-title mb-4">
        Welcome back
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input
          field={@form[:email]}
          class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          type="email"
          label="Email"
          required
        />
        <.input
          field={@form[:password]}
          class="py-2 px-4 block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 rounded-2xl bg-platinum border border-zinc-300 focus:outline-none focus:border-zinc-400"
          autocomplete="current-password"
          type="password"
          label="Password"
          required
        />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-zinc-500 text-underline">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <button
            phx-disable-with="Logging in..."
            class="w-full mt-2 px-4 py-2 cursor-pointer rounded-2xl text-sm font-medium font-body bg-light_red text-primary-foreground shadow-sm shadow-black/5 disabled:pointer-events-none disabled:opacity-50"
          >
            Log in <span aria-hidden="true">→</span>
          </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
