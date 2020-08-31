defmodule Dailyploy.Repo.Migrations.AlterProjectsTable do
  use Ecto.Migration

  def up do
    alter table(:projects) do
      add(:monthly_budget, :float, default: 0)
    end
  end

  def down do
    alter table(:projects) do
      remove(:monthly_budget, :float, default: 0)
    end
  end
end
