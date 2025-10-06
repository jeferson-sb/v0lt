defmodule Volt.Collections do
  @moduledoc """
  The Collections context.
  """

  alias Volt.{CollectionRepo, Collection.CollectionLikeRepo}

  @doc """
  Returns the list of collections with like information for a specific user.
  """
  def list_collections_with_likes(user_id) do
    CollectionRepo.all_with_likes(user_id)
  end

  @doc """
  Returns the list of collections.
  """
  def list_collections do
    CollectionRepo.all()
  end

  @doc """
  Gets a single collection.
  """
  def get_collection!(id) do
    CollectionRepo.get_collection!(id)
  end

  @doc """
  Creates a collection.
  """
  def create_collection(attrs \\ %{}) do
    CollectionRepo.create(attrs)
  end

  @doc """
  Updates a collection.
  """
  def update_collection(collection, attrs) do
    CollectionRepo.update(collection, attrs)
  end

  @doc """
  Deletes a collection.
  """
  def delete_collection(collection) do
    CollectionRepo.delete_collection(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.
  """
  def change_collection(collection, attrs \\ %{}) do
    CollectionRepo.change(collection, attrs)
  end

  @doc """
  Toggles a like for a collection by a user.
  """
  def toggle_like(user_id, collection_id) do
    CollectionRepo.toggle_like(user_id, collection_id)
  end

  @doc """
  Checks if a user has liked a specific collection.
  """
  def user_liked_collection?(user_id, collection_id) do
    CollectionLikeRepo.user_liked_collection?(user_id, collection_id)
  end

  @doc """
  Gets the total number of likes for a collection.
  """
  def count_likes(collection_id) do
    CollectionLikeRepo.count_likes(collection_id)
  end

  @doc """
  Gets all collections liked by a user.
  """
  def get_user_liked_collections(user_id) do
    CollectionLikeRepo.get_user_liked_collections(user_id)
  end
end
