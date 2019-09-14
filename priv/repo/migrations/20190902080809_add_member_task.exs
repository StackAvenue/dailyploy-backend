defmodule Dailyploy.Repo.Migrations.AddMemberTask do
  use Ecto.Migration

  def change do
    create table(:member_tasks) do
      add :member_id, references(:members, [on_delete: :delete_all])
      add :task_id, references(:tasks, [on_delete: :delete_all])
    end

    create index(:member_tasks, [:member_id, :task_id])
  end
end
