defmodule Dailyploy.Repo.Migrations.AddOwnerInProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :owner_id, :integer
      add :end_date, :date
    end

    create index(:projects, [:owner_id])
  end
end
