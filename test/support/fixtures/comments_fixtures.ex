defmodule Blog.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Comments` context.
  """

  import Blog.PostsFixtures

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    post = post_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content",
        post_id: post.id,
        user_id: post.user_id
      })
      |> Blog.Comments.create_comment()

    comment
  end
end
