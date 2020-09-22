defmodule Dailyploy.Repo.Migrations.AlterTimeTrack do
  use Ecto.Migration

  def change do
    alter table(:time_tracking) do
      add :logged_time, :integer, default: 0, null: false
    end
  end
end
