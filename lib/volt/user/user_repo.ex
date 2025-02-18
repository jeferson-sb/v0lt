defmodule Volt.UserRepo do
  alias Volt.Repo
  alias Volt.User

  def all do
    User |> Repo.all()
  end

  def find_or_create(attrs \\ %{}) do
    case User |> Repo.get_by(username: attrs["username"]) do
      %User{} = user ->
        {:ok, user}

      _ ->
        create(attrs)
    end
  end

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
