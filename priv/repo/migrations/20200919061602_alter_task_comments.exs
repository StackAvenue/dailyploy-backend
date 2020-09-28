defmodule Dailyploy.Repo.Migrations.AlterTaskComments do
  use Ecto.Migration

  def up do
    alter table(:task_comments) do
      add :user_stories_id, references(:user_stories, on_delete: :delete_all)
      add :task_list_tasks_id, references(:task_list_tasks, on_delete: :delete_all), null: true
    end
  end

  def down do
    drop constraint(:task_comments, "task_comments_user_stories_id_fkey")
    drop constraint(:task_comments, "task_comments_task_list_tasks_id_fkey")

    alter table(:task_comments) do
      remove :user_stories_id
      remove :task_list_tasks_id
    end
  end
end
