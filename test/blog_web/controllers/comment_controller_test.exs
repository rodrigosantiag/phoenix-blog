defmodule BlogWeb.CommentControllerTest do
  @moduledoc """
  Tests for the CommentController.
  """

  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.CommentsFixtures

  @create_attrs %{content: "some comment content"}

  @update_attrs %{
    content: "comment updated"
  }

  @invalid_attrs %{content: nil}

  describe "create comment" do
    setup [:register_and_log_in_user, :create_post]

    test "redirects to show when data is valid", %{conn: conn, post: post} do
      comment_attrs = Map.put(@create_attrs, :post_id, post.id)
      conn = post(conn, ~p"/comments", comment: comment_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "redirect to post when data is invalid", %{conn: conn, post: post} do
      comment_attrs = Map.put(@invalid_attrs, :post_id, post.id)
      conn = post(conn, ~p"/comments", comment: comment_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"
    end
  end

  describe "edit comment" do
    setup [:register_and_log_in_user, :create_comment]

    test "renders form for editing chosen post", %{conn: conn, comment: comment} do
      conn = get(conn, ~p"/comments/#{comment}/edit")
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:register_and_log_in_user, :create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{comment.post_id}"

      conn = get(conn, ~p"/posts/#{comment.post_id}")
      assert html_response(conn, 200) =~ "comment updated"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:register_and_log_in_user, :create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, ~p"/comments/#{comment}")
      assert redirected_to(conn) == ~p"/posts/#{comment.post_id}"
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end

  defp create_comment(_) do
    comment = comment_fixture()
    %{comment: comment}
  end
end
