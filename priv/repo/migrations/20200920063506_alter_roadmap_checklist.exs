defmodule Dailyploy.Repo.Migrations.AlterRoadmapChecklist do
  use Ecto.Migration

  def up do
    drop constraint(:roadmap_checklist, "roadmap_checklist_task_lists_id_fkey")

    alter table(:roadmap_checklist) do
      modify :task_lists_id, references(:task_lists, on_delete: :delete_all), null: true
      add :user_stories_id, references(:user_stories, on_delete: :delete_all)
      add :task_list_tasks_id, references(:task_list_tasks, on_delete: :delete_all), null: true
    end
  end

  def down do
    drop constraint(:roadmap_checklist, "roadmap_checklist_task_lists_id_fkey")
    drop constraint(:roadmap_checklist, "roadmap_checklist_user_stories_id_fkey")
    drop constraint(:roadmap_checklist, "roadmap_checklist_task_list_tasks_id_fkey")

    alter table(:roadmap_checklist) do
      modify :task_lists_id, references(:task_lists, on_delete: :delete_all), null: false
      remove :user_stories_id
      remove :task_list_tasks_id
    end
  end
end
