defmodule Blog.Posts.Post do
  @moduledoc """
  The Post schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :title, :string
    field :published_on, :date
    field :visible, :boolean, default: true

    has_many :comments, Blog.Comments.Comment
    belongs_to :user, Blog.Accounts.User
    many_to_many :tags, Blog.Tags.Tag, join_through: "posts_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visible, :user_id])
    |> validate_required([:title, :content, :visible, :user_id])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end
