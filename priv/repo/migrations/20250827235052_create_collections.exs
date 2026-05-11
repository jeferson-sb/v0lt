defmodule Volt.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :string
      add :likes, :integer, default: 0
      add :user_id, references(:users)

      timestamps(type: :utc_datetime)
    end
  end
end
