defmodule Volt.Repo.Migrations.AddLinkStatusFields do
  use Ecto.Migration

  def change do
    alter table(:urls) do
      add :status, :string, default: "unchecked"
      add :status_code, :integer
      add :last_checked_at, :utc_datetime
      add :check_attempts, :integer, default: 0
    end

    create index(:urls, [:status])
    create index(:urls, [:last_checked_at])
  end
end
