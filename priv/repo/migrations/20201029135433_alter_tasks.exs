defmodule Dailyploy.Repo.Migrations.AlterTasks do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      modify :name, :text
    end
  end

  def down do
    alter table(:tasks) do
      modify :name, :string
    end
  end
end
