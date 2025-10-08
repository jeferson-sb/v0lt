defmodule Volt.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :link, :string
    field :title, :string
    field :status, :string, default: "unchecked"
    field :status_code, :integer
    field :last_checked_at, :utc_datetime
    field :check_attempts, :integer, default: 0

    belongs_to(:collection, Volt.Collection)
    timestamps(type: :utc_datetime)
  end

  def changeset(url, attrs) do
    url
    |> cast(attrs, [:link, :title, :collection_id])
    |> validate_required([:link, :collection_id])
  end

  def status_changeset(url, attrs) do
    url
    |> cast(attrs, [:status, :status_code, :last_checked_at, :check_attempts])
    |> validate_inclusion(:status, ["unchecked", "live", "dead", "checking", "error"])
  end
end
