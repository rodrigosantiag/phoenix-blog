defmodule Blog.Repo.Migrations.AddUsernameToUsers do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, null: false, size: 40
    end
  end
end
