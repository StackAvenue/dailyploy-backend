defmodule Dailyploy.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:companies, [:email])
  end
end
