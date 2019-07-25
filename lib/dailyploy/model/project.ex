defmodule Dailyploy.Model.Project do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project

  def list_projects() do
    Repo.all(Project)
  end

  def get_project!(id), do: Repo.get(Project, id)

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end
end
