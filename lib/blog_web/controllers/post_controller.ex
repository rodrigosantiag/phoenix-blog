defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Accounts
  alias Blog.Comments
  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Tags

  plug :require_user_owns_post when action in [:edit, :update, :delete]

  def index(conn, %{"title" => title}) do
    posts = Posts.list_posts(title)
    render(conn, :index, posts: posts)
  end

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, :index, posts: posts)
  end

  @spec new(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, :new, changeset: changeset, tag_options: tag_options())
  end

  def create(conn, %{"post" => post_params}) do
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)

    case Posts.create_post(post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          changeset: changeset,
          tag_options: tag_options(Enum.map(tags, & &1["id"]))
        )
    end
  end

  def create(conn, %{"comment" => comment_params}) do
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        post = Posts.get_post!(comment_params["post_id"])
        render(conn, :show, post: post, comment_changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    user = Accounts.get_user!(post.user_id)

    comment_changeset = Comments.change_comment(%Comments.Comment{})

    render(conn, :show,
      post: post,
      comment_changeset: comment_changeset,
      user_id: Map.get(conn.assigns[:current_user] || %{}, :id),
      username: user.username
    )
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)

    render(conn, :edit,
      post: post,
      changeset: changeset,
      tag_options: tag_options(Enum.map(post.tags, & &1.id))
    )
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)

    case Posts.update_post(post, post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          post: post,
          changeset: changeset,
          tag_options: tag_options(Enum.map(post.tags, & &1.id))
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own posts.")
      |> redirect(to: ~p"/posts")
      |> halt()
    end
  end

  defp tag_options(selected_ids \\ []) do
    Tags.list_tags()
    |> Enum.map(fn tag ->
      [key: tag.name, value: tag.id, selected: tag.id in selected_ids]
    end)
  end
end
