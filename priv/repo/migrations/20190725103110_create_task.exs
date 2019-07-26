defmodule Dailyploy.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :description, :string
      add :type, :integer
      add :start_date, :timestamptz
      add :end_date, :timestamptz
      add :project_id, :integer

      timestamps(type: :timestamptz)
    end
  end
end
