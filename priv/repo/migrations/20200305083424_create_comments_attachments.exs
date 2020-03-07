defmodule Dailyploy.Repo.Migrations.CreateCommentsAttachments do
  use Ecto.Migration

  def change do
    create table(:comments_attachments) do
      add :task_id, references(:users, on_delete: :delete_all)
      add :task_comment_id, references(:task_comments, on_delete: :delete_all)
      add :image_url, :string

      timestamps()
    end
  end
end
