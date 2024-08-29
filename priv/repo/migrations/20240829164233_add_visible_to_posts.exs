defmodule Blog.Repo.Migrations.AddVisibleToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :visible, :boolean, default: true
    end
  end
end
