defmodule BlogWeb.CommentControllerTest do
  @moduledoc """
  Tests for the CommentController.
  """
  alias Blog.Accounts

  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.CommentsFixtures
  import Blog.AccountsFixtures

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
    setup do
      comment = comment_fixture()
      user = Accounts.get_user!(comment.user_id)
      %{comment: comment, user: user}
    end

    test "renders form for editing chosen post", %{conn: conn, comment: comment, user: user} do
      conn = conn |> log_in_user(user) |> get(~p"/comments/#{comment}/edit")
      assert html_response(conn, 200) =~ "Edit Comment"
    end

    test "user cannot edit other user's comment", %{conn: conn, comment: comment} do
      another_user = user_fixture()
      conn = conn |> log_in_user(another_user) |> get(~p"/comments/#{comment}/edit")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You can only edit or delete your own comments."
    end
  end

  describe "update comment" do
    setup do
      comment = comment_fixture()
      user = Accounts.get_user!(comment.user_id)

      %{comment: comment, user: user}
    end

    test "redirects when data is valid", %{conn: conn, comment: comment, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/comments/#{comment}", comment: @update_attrs)

      assert redirected_to(conn) == ~p"/posts/#{comment.post_id}"

      conn = get(conn, ~p"/posts/#{comment.post_id}")
      assert html_response(conn, 200) =~ "comment updated"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/comments/#{comment}", comment: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Comment"
    end

    test "user cannot update other user's comment", %{conn: conn, comment: comment} do
      another_user = user_fixture()

      conn =
        conn |> log_in_user(another_user) |> put(~p"/comments/#{comment}", comment: @update_attrs)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You can only edit or delete your own comments."
    end
  end

  describe "delete comment" do
    setup [:register_and_log_in_user, :create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, ~p"/comments/#{comment}")
      assert redirected_to(conn) == ~p"/posts/#{comment.post_id}"
    end

    test "user cannot delete other user's comment", %{conn: conn, comment: comment} do
      another_user = user_fixture()
      conn = conn |> log_in_user(another_user) |> delete(~p"/comments/#{comment}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You can only edit or delete your own comments."
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
