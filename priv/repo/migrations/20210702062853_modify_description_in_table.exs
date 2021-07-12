defmodule Dailyploy.Repo.Migrations.ModifyDescriptionInTable do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      modify :description, :text
    end
  end

  def down do
    alter table(:tasks) do
      modify :description, :string
    end
  end
end
