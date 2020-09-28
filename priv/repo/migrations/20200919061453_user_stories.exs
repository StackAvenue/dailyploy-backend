defmodule Dailyploy.Repo.Migrations.UserStories do
  use Ecto.Migration

  def change do
    create table(:user_stories) do
      add :name, :string
      add :description, :text
      add :priority, :string
      add :due_date, :utc_datetime
      add :task_status_id, references(:task_status, on_delete: :restrict)
      add :owner_id, references(:users, on_delete: :delete_all), null: true
      add :task_lists_id, references(:task_lists, on_delete: :delete_all), null: false
      add :is_completed, :boolean, default: false, null: false
      timestamps()
    end
  end
end
