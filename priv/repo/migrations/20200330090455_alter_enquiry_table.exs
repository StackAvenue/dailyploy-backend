defmodule Dailyploy.Repo.Migrations.AlterEnquiryTable do
  use Ecto.Migration

  def up do
    alter table(:enquires) do
      add :company_name, :string, null: false
      modify :comment, :text
    end
  end

  def down do
    alter table(:enquires) do
      remove :company_name
      modify :comment, :string
    end
  end
end
