defmodule VoltWeb.CommunityController do
  use VoltWeb, :controller

  def index(conn, params) do
    conn
    |> render(:index, layout: false, users: Volt.UserRepo.collections())
  end
end
