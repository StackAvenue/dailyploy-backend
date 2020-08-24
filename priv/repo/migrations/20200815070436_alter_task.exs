defmodule Dailyploy.Repo.Migrations.AlterTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :is_complete, :boolean, default: false, null: false
    end
  end
end
