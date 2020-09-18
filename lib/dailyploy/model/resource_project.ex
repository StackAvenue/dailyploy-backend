defmodule Dailyploy.Model.ResourceProject do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project

  import Ecto.Query

  def fetch_projects(workspace_id) do
    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id,
        order_by: project.name

    Repo.all(query)
  end
end
