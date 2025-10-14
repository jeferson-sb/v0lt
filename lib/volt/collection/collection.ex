defmodule Volt.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :name, :string
    field :color, :string
    field :tags, {:array, :string}, default: []

    belongs_to(:user, Volt.Accounts.User)
    has_many(:urls, Volt.Url, on_delete: :delete_all)
    has_many(:collection_likes, Volt.Collection.CollectionLike, on_delete: :delete_all)
    has_many(:liked_by_users, through: [:collection_likes, :user])

    timestamps(type: :utc_datetime)
  end

  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :user_id, :color, :tags])
    |> trim_array(:tags)
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name)
  end

  def trim_array(changeset, field, blank \\ "") do
    update_change(changeset, field, &Enum.reject(&1, fn item -> item == blank end))
  end
end
