defmodule :"Elixir.Dailyploy.Repo.Migrations.Dailyploy-checklist" do
  use Ecto.Migration

  def change do
    create table(:roadmap_checklist) do
      add :name, :string
      add :task_lists_id, references(:task_lists, on_delete: :delete_all), null: false
      add :is_completed, :boolean, default: false, null: false
      timestamps()
    end
  end
end
