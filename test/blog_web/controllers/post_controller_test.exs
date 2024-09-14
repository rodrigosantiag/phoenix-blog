defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.AccountsFixtures
  import Blog.PostsFixtures
  import Blog.CommentsFixtures

  alias Blog.Accounts

  @create_attrs %{content: "some content", subtitle: "some subtitle", title: "some title"}

  @update_attrs %{
    content: "some updated content",
    subtitle: "some updated subtitle",
    title: "some updated title"
  }

  @invalid_attrs %{content: nil, subtitle: nil, title: nil}

  describe "index" do
    setup :register_and_log_in_user

    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end

    test "searches for posts - exact match", %{conn: conn} do
      post = post_fixture(title: "some title")
      conn = get(conn, ~p"/posts", title: "some title")
      assert html_response(conn, 200) =~ post.title
    end

    test "searches for posts - partial match", %{conn: conn} do
      post = post_fixture(title: Faker.App.author() <> "tle")
      conn = get(conn, ~p"/posts", title: "tle")
      assert html_response(conn, 200) =~ post.title
    end

    test "searches for posts - non-matching", %{conn: conn} do
      post = post_fixture()
      conn = get(conn, ~p"/posts", title: "Non-Matching")
      refute html_response(conn, 200) =~ post.title
    end
  end

  describe "new post" do
    setup :register_and_log_in_user

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    setup :register_and_log_in_user

    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      create_attrs = Map.put(@create_attrs, :user_id, user.id)
      conn = post(conn, ~p"/posts", post: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post} do
      user = Accounts.get_user!(post.user_id)
      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "a user cannot edit another user's post", %{conn: conn, post: post} do
      another_user = user_fixture()
      conn = conn |> log_in_user(another_user) |> get(~p"/posts/#{post}/edit")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You can only edit or delete your own posts."
    end
  end

  describe "update post" do
    setup do
      post = post_fixture()
      user = Accounts.get_user!(post.user_id)

      %{post: post, user: user}
    end

    test "redirects when data is valid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup do
      post = post_fixture()
      user = Accounts.get_user!(post.user_id)

      %{post: post, user: user}
    end

    test "deletes chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  describe "get post with comments" do
    setup do
      post = post_fixture()
      user = Accounts.get_user!(post.user_id)

      %{post: post, user: user}
    end

    test "shows post with comments", %{conn: conn, post: post, user: user} do
      comment = comment_fixture(post_id: post.id)
      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}")
      assert html_response(conn, 200) =~ post.title
      assert html_response(conn, 200) =~ comment.content
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
