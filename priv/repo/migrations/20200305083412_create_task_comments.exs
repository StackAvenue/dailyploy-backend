defmodule Dailyploy.Repo.Migrations.CreateTaskComments do
  use Ecto.Migration

  def change do
    create table(:task_comments) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :comments, :text

      timestamps()
    end
  end
end
