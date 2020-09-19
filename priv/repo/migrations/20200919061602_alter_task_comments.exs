defmodule Dailyploy.Repo.Migrations.AlterTaskComments do
  use Ecto.Migration

  def up do
    alter table(:task_comments) do
      add :user_stories_id, references(:user_stories, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint(:task_comments, "task_comments_story_id_fkey")

    alter table(:task_comments) do
      remove :user_stories_id
    end
  end
end
