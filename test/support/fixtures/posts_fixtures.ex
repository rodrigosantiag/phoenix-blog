defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  import Blog.AccountsFixtures

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    user = user_fixture()
    tags = attrs[:tags] || []

    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: Faker.App.author(),
        published_on: NaiveDateTime.utc_now(),
        visible: true,
        user_id: user.id
      })
      |> Blog.Posts.create_post(tags)

    post
  end
end
