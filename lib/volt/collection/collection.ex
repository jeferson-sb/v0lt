defmodule Volt.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :name, :string
    field :color, :string

    belongs_to(:user, Volt.Accounts.User)
    has_many(:urls, Volt.Url, on_delete: :delete_all)
    has_many(:collection_likes, Volt.Collection.CollectionLike, on_delete: :delete_all)
    has_many(:liked_by_users, through: [:collection_likes, :user])

    timestamps(type: :utc_datetime)
  end

  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :user_id, :color])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name)
  end
end
