defmodule Dailyploy.Repo.Migrations.AddUserToTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :user_id, references(:users, [on_delete: :delete_all])
    end

    create index(:tasks, [:user_id])
  end
end
