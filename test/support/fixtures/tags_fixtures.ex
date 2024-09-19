defmodule Blog.TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Tags` context.
  """

  alias Blog.Tags

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{name: Faker.App.author()})
      |> Tags.create_tag()

    tag
  end
end
