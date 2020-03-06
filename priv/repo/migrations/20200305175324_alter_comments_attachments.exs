defmodule Dailyploy.Repo.Migrations.AlterCommentsAttachments do
  use Ecto.Migration

  def up do
    alter table(:comments_attachments) do
      remove :task_id
    end
  end

  def down do
    alter table(:comments_attachments) do
      add :task_id, references(:users, on_delete: :delete_all)
    end
  end
end
