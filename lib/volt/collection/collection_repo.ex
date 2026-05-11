defmodule Volt.CollectionRepo do
  alias Volt.Repo
  alias Volt.Collection
  alias Volt.Collection.CollectionLikeRepo
  import Ecto.Query

  def all do
    Collection |> Repo.all()
  end

  def create(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  def change(%Collection{} = collection, attrs \\ %{}) do
    Collection.changeset(collection, attrs)
  end

  def get_collection!(id) do
    Collection
    |> Repo.get_by(id: id)
  end

  def get_user_collections(user_id) do
    Collection
    |> Repo.all_by(user_id: user_id)
  end

  def delete_collection(collection) do
    collection
    |> Repo.delete()
  end

  def update(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets all collections with their like counts and whether a specific user has liked them.
  Returns everything in a single query (no N+1).
  """
  def all_with_likes(user_id \\ nil) do
    from(c in Collection,
      left_join: cl in assoc(c, :collection_likes),
      left_join: ul in Volt.Collection.CollectionLike,
      on: ul.collection_id == c.id and ul.user_id == ^user_id,
      group_by: c.id,
      select: %{
        collection: c,
        likes_count: count(cl.id),
        user_liked: count(ul.id) > 0
      }
    )
    |> Repo.all()
  end

  @doc """
  Toggles a like for a collection by a user.
  """
  def toggle_like(user_id, collection_id) do
    CollectionLikeRepo.toggle_like(user_id, collection_id)
  end
end
