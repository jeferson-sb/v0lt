defmodule Volt.UrlRepo do
  alias Volt.Repo
  alias Volt.Url

  def all do
    Url |> Repo.all()
  end

  def create(attrs \\ %{}) do
    %Url{}
    |> Url.changeset(attrs)
    |> Repo.insert()
  end

  def change(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end
end
