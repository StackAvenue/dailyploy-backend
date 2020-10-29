defmodule Dailyploy.Repo.Migrations.AlterDataTypes do
  use Ecto.Migration

  def up do
    alter table(:task_list_tasks) do
      modify :name, :text
    end
  end

  def down do
    alter table(:task_list_tasks) do
      modify :name, :string
    end
  end
end
