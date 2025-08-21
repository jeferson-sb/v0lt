defmodule Volt.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :link, :string
      add :title, :string
      add :collection_id, references(:collections)

      timestamps(type: :utc_datetime)
    end
  end
end
