defmodule Blog.Repo.Migrations.CreateTagsTable do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :text

      timestamps(type: :utc_datetime)
    end
  end
end
