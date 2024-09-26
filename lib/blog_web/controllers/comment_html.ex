defmodule BlogWeb.CommentHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use BlogWeb, :html

  embed_templates "comment_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :current_user, Blog.Accounts.User, required: false

  def comment_form(assigns)
end
