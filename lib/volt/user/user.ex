defmodule Volt.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :username, :string

    has_many(:collections, Volt.Collection, on_delete: :delete_all)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
