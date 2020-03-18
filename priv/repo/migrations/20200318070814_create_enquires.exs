defmodule Dailyploy.Repo.Migrations.CreateEnquires do
  use Ecto.Migration

  def change do
    create table(:enquires) do
      add :phone_number, :string
      add :email, :string
      add :name, :string
      add :comment, :string
      timestamps()
    end
  end
end
