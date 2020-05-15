defmodule Dailyploy.Repo.Migrations.AddProjectTaskList do
  use Ecto.Migration

  def change do
    create table(:add_project_task_list) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :description, :text
      add :color_code, :string
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:add_project_task_list, [:project_id])
    create unique_index(:add_project_task_list, [:project_id], name: :unique_project_index)
  end
end
