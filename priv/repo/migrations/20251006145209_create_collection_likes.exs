defmodule Volt.Repo.Migrations.CreateCollectionLikes do
  use Ecto.Migration

  def change do
    create table(:collection_likes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :collection_id, references(:collections, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:collection_likes, [:user_id, :collection_id])
    create index(:collection_likes, [:collection_id])
    create index(:collection_likes, [:user_id])

    alter table(:collections) do
      remove :likes
    end
  end
end
