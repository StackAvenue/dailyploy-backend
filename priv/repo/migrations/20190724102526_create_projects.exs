defmodule Dailyploy.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :description, :text
      add :color_code, :string
      add :owner_id, :integer
      add :workspace_id, :integer

      timestamps()
    end

    create index(:projects, [:owner_id, :workspace_id])

    create unique_index(:projects, [:workspace_id, :name],
             name: :unique_index_for_project_name_and_workspace_id_in_project
           )
  end
end
