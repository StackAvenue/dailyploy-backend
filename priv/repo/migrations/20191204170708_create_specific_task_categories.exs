defmodule Dailyploy.Repo.Migrations.CreateSpecificTaskCategories do
  use Ecto.Migration

  def change do
    create table(:specific_task_categories) do
      add(:task_id, references(:tasks), on_delete: :delete_all, null: false)
      add(:task_category_id, references(:task_categories), null: false)
    end

    create unique_index(:specific_task_categories, [:task_id, :task_category_id],
             name: :unique_index_for_task_and_category
           )
  end
end
