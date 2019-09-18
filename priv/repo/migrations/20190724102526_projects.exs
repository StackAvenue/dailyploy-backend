defmodule Dailyploy.Repo.Migrations.Project do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :start_date, :date
      add :description, :text
      add :color_code, :string
      timestamps()
    end

    create unique_index(:projects, [:name])
  end
end
