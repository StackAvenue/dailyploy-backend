defmodule Dailyploy.Repo.Migrations.AddUniqueIndexInRolesName do
  use Ecto.Migration

  def change do
    create unique_index(:roles, [:name])
  end
end
