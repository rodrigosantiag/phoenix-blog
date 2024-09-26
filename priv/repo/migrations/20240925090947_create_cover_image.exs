defmodule Blog.Repo.Migrations.CreateCoverImage do
  @moduledoc """
  Create cover_image table
  """

  use Ecto.Migration

  def change do
    create table(:cover_images) do
      add :url, :text
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:cover_images, [:post_id])
  end
end
