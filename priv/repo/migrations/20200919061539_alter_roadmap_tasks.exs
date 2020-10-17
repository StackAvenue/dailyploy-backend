defmodule Dailyploy.Repo.Migrations.AlterRoadmapTasks do
  use Ecto.Migration

  def up do
    drop constraint(:task_list_tasks, "task_list_tasks_task_lists_id_fkey")

    alter table(:task_list_tasks) do
      modify :task_lists_id, references(:task_lists, on_delete: :delete_all), null: true
      add :user_stories_id, references(:user_stories, on_delete: :delete_all), null: true
    end
  end

  def down do
    drop constraint(:task_list_tasks, "task_list_tasks_task_lists_id_fkey")
    drop constraint(:task_list_tasks, "task_list_tasks_user_stories_id_fkey")

    alter table(:task_list_tasks) do
      modify :task_lists_id, references(:task_lists, on_delete: :delete_all), null: true
      remove :user_stories_id
    end
  end
end
