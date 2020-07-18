defmodule Dailyploy.Repo.Migrations.CreateTaskLists do
  use Ecto.Migration

  def change do
    create table(:task_lists) do
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

    create index(:task_lists, [:project_id])
    create unique_index(:task_lists, [:name, :project_id], name: :unique_name_per_project)
  end
end
