defmodule Blog.Repo.Migrations.MakeTitleUnique do
  use Ecto.Migration

  def change do
    create(unique_index(:posts, [:title]))
  end
end
