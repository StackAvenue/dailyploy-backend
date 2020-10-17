defmodule Dailyploy.Repo.Migrations.AlterWorkspace do
  use Ecto.Migration

  def change do
    alter table(:workspaces) do
      add :timetrack_enabled, :boolean, default: true, null: false
    end
  end
end
