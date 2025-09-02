defmodule Volt.CollectionRepo do
  alias Volt.Repo
  alias Volt.Collection

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

  def add_favorite(collection) do
    collection
    |> Collection.changeset(%{likes: collection[:likes] + 1})
    |> Repo.update()
  end
end
