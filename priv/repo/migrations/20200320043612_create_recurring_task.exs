defmodule Dailyploy.Repo.Migrations.CreateRecurringTask do
  use Ecto.Migration

  def change do
    create table(:recurring_tasks) do
      add :name, :string
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
      add :comments, :text
      add :project_ids, {:array, :integer}
      add :member_ids, {:array, :integer}
      add :category_id, references(:task_categories, on_delete: :delete_all)
      add :status, :string
      add :priority, :string
      add :frequency, :string
      add :number, :integer
      add :schedule, :boolean, default: true
      add :week_numbers, {:array, :integer}
      add :month_numbers, {:array, :integer}
      add :workspace_id, references(:workspaces, on_delete: :delete_all)
      add :project_members_combination, :map

      timestamps()
    end
  end
end
