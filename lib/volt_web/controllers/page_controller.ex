defmodule VoltWeb.PageController do
  use VoltWeb, :controller
  alias Volt.User

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, :new, layout: false, changeset: changeset)
  end

  def create(conn, %{"user" => user} = params) do
    user |> Volt.UserRepo.find_or_create()

    conn
    |> redirect(to: "/links", username: "test1")
    |> halt()
  end
end
