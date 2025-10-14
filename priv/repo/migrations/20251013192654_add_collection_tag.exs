defmodule Volt.Repo.Migrations.AddCollectionTag do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      add :tags, {:array, :string}
    end
  end
end
