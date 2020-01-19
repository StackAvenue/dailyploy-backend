defmodule Dailyploy.Repo.Migrations.AlterTimeTrackingTable do
  use Ecto.Migration

  def change do
    alter table(:time_tracking) do
      add :time_log, :boolean, default: false
    end
  end
end
