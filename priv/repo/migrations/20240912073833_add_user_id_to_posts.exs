defmodule Blog.Repo.Migrations.AddUserIdToPosts do
  @moduledoc """
  Add user_id to posts
  """

  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
