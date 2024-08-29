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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visible])
    |> validate_required([:title, :content, :visible])
  end
end
