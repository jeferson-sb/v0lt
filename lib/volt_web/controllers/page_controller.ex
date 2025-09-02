defmodule VoltWeb.PageController do
  use VoltWeb, :controller
  alias Volt.Accounts.User

  def new(conn, _params) do
    changeset = User.registration_changeset(%User{}, %{})
    render(conn, :new, layout: false, changeset: changeset)
  end

  def create(conn, %{"user" => user} = params) do
    user |> Volt.UserRepo.find_or_create()

    conn
    |> redirect(to: "/")
    |> halt()
  end
end
