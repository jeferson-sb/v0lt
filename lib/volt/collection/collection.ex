defmodule Volt.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :name, :string
    field :likes, :integer

    belongs_to(:user, Volt.User)
    has_many(:urls, Volt.Url, on_delete: :delete_all)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    # is user_id required?
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name)
  end
end
