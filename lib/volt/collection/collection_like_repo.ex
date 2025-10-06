defmodule Volt.Collection.CollectionLikeRepo do
  alias Volt.Repo
  alias Volt.Collection.CollectionLike
  import Ecto.Query

  @doc """
  Toggles a like for a collection by a user.
  If the user has already liked the collection, it removes the like.
  If the user hasn't liked it, it adds a like.
  Returns {:ok, :liked} or {:ok, :unliked}
  """
  def toggle_like(user_id, collection_id) do
    case get_like(user_id, collection_id) do
      nil ->
        add_like(user_id, collection_id)
        {:ok, :liked}

      like ->
        remove_like(like)
        {:ok, :unliked}
    end
  end

  @doc """
  Adds a like for a collection by a user.
  Returns {:ok, collection_like} or {:error, changeset}
  """
  def add_like(user_id, collection_id) do
    %CollectionLike{}
    |> CollectionLike.changeset(%{user_id: user_id, collection_id: collection_id})
    |> Repo.insert()
  end

  @doc """
  Removes a like for a collection by a user.
  """
  def remove_like(%CollectionLike{} = like) do
    Repo.delete(like)
  end

  @doc """
  Gets a specific like record for a user and collection.
  Returns the CollectionLike or nil if not found.
  """
  def get_like(user_id, collection_id) do
    CollectionLike
    |> where([cl], cl.user_id == ^user_id and cl.collection_id == ^collection_id)
    |> Repo.one()
  end

  @doc """
  Checks if a user has liked a specific collection.
  Returns true or false.
  """
  def user_liked_collection?(user_id, collection_id) do
    CollectionLike
    |> where([cl], cl.user_id == ^user_id and cl.collection_id == ^collection_id)
    |> Repo.exists?()
  end

  @doc """
  Gets the total number of likes for a collection.
  """
  def count_likes(collection_id) do
    CollectionLike
    |> where([cl], cl.collection_id == ^collection_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets all collections liked by a user.
  """
  def get_user_liked_collections(user_id) do
    from(cl in CollectionLike,
      where: cl.user_id == ^user_id,
      join: c in assoc(cl, :collection),
      select: c,
      preload: [:user]
    )
    |> Repo.all()
  end
end
