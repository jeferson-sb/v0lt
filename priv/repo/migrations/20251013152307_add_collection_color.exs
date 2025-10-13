defmodule Volt.Repo.Migrations.AddCollectionColor do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      add :color, :string
    end
  end
end
