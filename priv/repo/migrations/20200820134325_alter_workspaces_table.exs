defmodule Dailyploy.Repo.Migrations.AlterWorkspacesTable do
  use Ecto.Migration

  def up do
    alter table(:workspaces) do
      add :currency, :string
    end
  end
end
