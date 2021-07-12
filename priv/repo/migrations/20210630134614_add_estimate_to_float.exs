defmodule Dailyploy.Repo.Migrations.AddEstimateToFloat do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      modify :estimation, :float
    end
  end

  def down do
    alter table(:tasks) do
      modify :estimation, :float
    end
  end
end
