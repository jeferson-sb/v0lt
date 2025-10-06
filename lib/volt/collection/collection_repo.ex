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
  """
  def all_with_likes(user_id \\ nil) do
    query =
      from c in Collection,
        left_join: cl in assoc(c, :collection_likes),
        group_by: c.id,
        select: %{
          collection: c,
          likes_count: count(cl.id)
        }

    results = Repo.all(query)

    if user_id do
      # Add user_liked field to each result
      Enum.map(results, fn %{collection: collection, likes_count: likes_count} ->
        user_liked = CollectionLikeRepo.user_liked_collection?(user_id, collection.id)
        %{collection: collection, likes_count: likes_count, user_liked: user_liked}
      end)
    else
      # Add user_liked as false for all results when no user_id provided
      Enum.map(results, fn %{collection: collection, likes_count: likes_count} ->
        %{collection: collection, likes_count: likes_count, user_liked: false}
      end)
    end
  end

  @doc """
  Toggles a like for a collection by a user.
  """
  def toggle_like(user_id, collection_id) do
    CollectionLikeRepo.toggle_like(user_id, collection_id)
  end
end
