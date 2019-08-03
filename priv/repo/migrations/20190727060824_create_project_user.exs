defmodule Dailyploy.Repo.Migrations.CreateProjectUser do
  use Ecto.Migration

  def change do
    create table(:project_users) do
      add :user_id, :integer
      add :project_id, :integer

      timestamps()
    end

    create unique_index(:project_users, [:user_id, :project_id],
             name: :unique_index_for_user_and_project_in_projectuser
           )
  end
end
