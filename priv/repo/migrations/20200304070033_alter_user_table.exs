defmodule Dailyploy.Repo.Migrations.AlterUserTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :provider, :string
      add :provider_id, :string
      add :provider_img, :string
    end
  end
end
