defmodule Dailyploy.Repo.Migrations.AlertStatus do
  use Ecto.Migration

  def change do
    alter table(:task_status) do
      add :sequence_no, :integer, default: 0, null: false
      add :is_default, :boolean, default: false, null: false
    end
  end
end
