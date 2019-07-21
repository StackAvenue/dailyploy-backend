defmodule Dailyploy.Repo.Migrations.AddUniqueIndexForEmailInCompanies do
  use Ecto.Migration

  def change do
    create unique_index(:companies, [:email])
  end
end
