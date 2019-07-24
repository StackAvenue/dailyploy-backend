defmodule Dailyploy.Repo.Migrations.Project do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :start_date, :date
      add :description, :text
      timestamps()
    end
  end
end
