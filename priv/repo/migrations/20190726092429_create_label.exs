defmodule Dailyploy.Repo.Migrations.CreateLabel do
  use Ecto.Migration

  def change do
    create table(:labels) do
      add :tag_id, :integer
      add :task_id, :integer

      timestamps()
    end

    create unique_index(:labels, [:tag_id, :task_id],
             name: :unique_index_for_tag_and_task_in_label
           )
  end
end
