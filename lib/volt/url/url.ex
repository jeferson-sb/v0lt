defmodule Volt.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :link, :string
    field :title, :string

    belongs_to(:collection, Volt.Collection)
    timestamps(type: :utc_datetime)
  end

  def changeset(url, attrs) do
    url
    |> cast(attrs, [:link, :title, :collection_id])
    |> validate_required([:link, :collection_id])
  end
end
