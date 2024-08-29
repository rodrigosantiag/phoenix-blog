defmodule Blog.Repo.Migrations.RemoveSubtitleColumn do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :subtitle
    end
  end
end
