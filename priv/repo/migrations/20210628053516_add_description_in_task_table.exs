defmodule Dailyploy.Repo.Migrations.AddDescriptionInTaskTable do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      add :description, :string
    end
  end

  def down do
    alter table(:tasks) do
      remove :description
    end
  end
end
