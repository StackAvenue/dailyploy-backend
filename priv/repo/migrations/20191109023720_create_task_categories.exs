defmodule Dailyploy.Repo.Migrations.CreateTaskCategories do
  use Ecto.Migration

  def change do
    create table(:task_categories) do
      add :name, :string

      timestamps()
    end
  end
end
