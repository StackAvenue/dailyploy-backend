defmodule Dailyploy.Schema.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Project

  schema "project_users" do
    belongs_to :user, User
    belongs_to :project, Project

    timestamps()
  end

  def changeset(projectuser, attrs) do
  projectuser
  |> cast(attrs, [:user_id, :project_id])
  |> validate_required([:user_id, :project_id])
  |> unique_constraint(:user_project_uniqueness, name: :unique_index_for_user_and_project_in_projectuser)
  end
end
