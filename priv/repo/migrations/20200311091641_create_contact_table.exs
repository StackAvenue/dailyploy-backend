defmodule Dailyploy.Repo.Migrations.CreateContactTable do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :phone_number, :string
      add :email, :string
      add :name, :string

      timestamps()
    end

    create unique_index(:contacts, [:email, :phone_number, :project_id],
             name: :unique_contact_index
           )
  end
end
