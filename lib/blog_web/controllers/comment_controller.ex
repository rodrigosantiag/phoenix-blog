defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Comments

  plug :require_user_owns_comment when action in [:edit, :update, :delete]

  def create(conn, %{"comment" => comment_params}) do
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}")

      {:error, %Ecto.Changeset{} = comment_changeset} ->
        redirect(conn,
          to: "/posts/#{comment_params["post_id"]}",
          comment_changeset: comment_changeset
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, :edit, comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: ~p"/posts/#{comment.post_id}")
  end

  defp require_user_owns_comment(conn, _params) do
    comment_id = String.to_integer(conn.path_params["id"])
    comment = Comments.get_comment!(comment_id)

    if conn.assigns[:current_user].id != comment.user_id do
      conn
      |> put_flash(:error, "You can only edit or delete your own comments.")
      |> redirect(to: "/posts/#{comment.post_id}")
      |> halt()
    else
      conn
    end
  end
end
