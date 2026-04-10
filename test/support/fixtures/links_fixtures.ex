defmodule Reddit.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Reddit.Links` context.
  """

  @doc """
  Generate a link.
  """
  def link_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        points: 42,
        title: "some title",
        url: "some url"
      })

    {:ok, link} = Reddit.Links.create_link(scope, attrs)
    link
  end
end
