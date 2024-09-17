defmodule Blog.Repo.Migrations.AddUserIdToComments do
  @moduledoc """
  Add user_id to comments
  """
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
