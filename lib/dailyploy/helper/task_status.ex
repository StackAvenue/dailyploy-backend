defmodule Dailyploy.Helper.TaskStatus do
  alias Dailyploy.Model.TaskStatus, as: TSModel
  alias Dailyploy.Repo
  import DailyployWeb.Helpers

  defdelegate get(id), to: TSModel
  defdelegate update(task_status, params), to: TSModel
  defdelegate delete(task_status), to: TSModel

  def create(params) do
    %{
      project_id: project_id,
      workspace_id: workspace_id,
      name: name
    } = params

    verify_create(
      TSModel.create(%{
        project_id: project_id,
        workspace_id: workspace_id,
        name: name
      })
    )
  end

  defp verify_create({:ok, status}) do
    status = status |> Repo.preload([:project, :workspace])

    {:ok,
     %{
       id: status.id,
       project_id: status.project_id,
       workspace_id: status.workspace_id,
       name: status.name,
       project: status.project,
       workspace: status.workspace,
       inserted_at: status.inserted_at
     }}
  end

  defp verify_create({:error, status}) do
    {:error, %{error: extract_changeset_error(status)}}
  end
end
