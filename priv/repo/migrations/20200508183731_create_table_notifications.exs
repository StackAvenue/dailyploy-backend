defmodule Dailyploy.Repo.Migrations.CreateTableNotifications do
  use Ecto.Migration

  def up do
    create table(:notifications) do
      add(:data, :map)
      add(:read, :boolean, default: false)
      add(:receiver_id, references(:users, on_delete: :delete_all), null: false)
      add(:creator_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end
  end

  def down do
    drop(table(:notifications))
  end
end
