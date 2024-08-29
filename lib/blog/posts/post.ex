defmodule Blog.Posts.Post do
  @moduledoc """
  The Post schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :subtitle, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :subtitle, :content])
    |> validate_required([:title, :subtitle, :content])
  end
end
