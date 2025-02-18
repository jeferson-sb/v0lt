defmodule Volt.CollectionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.Collection` context.
  """

  @doc """
  Generate a url.
  """
  def url_fixture(attrs \\ %{}) do
    {:ok, url} =
      attrs
      |> Enum.into(%{
        link: "some link",
        title: "some title"
      })
      |> Volt.Collection.create_url()

    url
  end
end
