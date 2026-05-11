defmodule Volt.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    create index(:collections, [:user_id])
    create index(:urls, [:collection_id])
  end
end
