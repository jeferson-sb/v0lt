defmodule Volt.Collection.CollectionLike do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collection_likes" do
    belongs_to(:user, Volt.Accounts.User)
    belongs_to(:collection, Volt.Collection)

    timestamps(type: :utc_datetime)
  end

  def changeset(collection_like, attrs) do
    collection_like
    |> cast(attrs, [:user_id, :collection_id])
    |> validate_required([:user_id, :collection_id])
    |> unique_constraint([:user_id, :collection_id])
  end
end
