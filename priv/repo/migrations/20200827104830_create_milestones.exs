defmodule Dailyploy.Repo.Migrations.CreateMilestones do
  use Ecto.Migration

  def change do
    create table(:milestones) do
      add :name, :string, null: false
      add :description, :text
      add :due_date, :utc_datetime, null: false
      add :status, :integer, default: 0
      add :project_id, references(:projects)

      timestamps()
    end
  end
end
