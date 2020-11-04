defmodule Dailyploy.Helper.TaskLists do
  alias Dailyploy.Repo
  alias Dailyploy.Model.TaskLists, as: PTModel
  import DailyployWeb.Helpers

  def create(params) do
    %{
      name: name,
      start_date: start_date,
      end_date: end_date,
      category_id: category_id,
      description: description,
      color_code: color_code,
      status: status,
      workspace_id: workspace_id,
      creator_id: creator_id,
      project_id: project_id
    } = params

    verify_create(
      PTModel.create(%{
        name: name,
        start_date: start_date,
        end_date: end_date,
        description: description,
        category_id: category_id,
        color_code: color_code,
        workspace_id: workspace_id,
        status: status,
        creator_id: creator_id,
        project_id: project_id
      })
    )
  end

  defp verify_create({:ok, project_task_list}) do
    project_task_list =
      project_task_list |> Repo.preload([:project, :workspace, :category, :creator])

    {:ok,
     %{
       id: project_task_list.id,
       name: project_task_list.name,
       status: project_task_list.status,
       start_date: project_task_list.start_date,
       end_date: project_task_list.end_date,
       description: project_task_list.description,
       color_code: project_task_list.color_code,
       workspace_id: project_task_list.workspace_id,
       creator_id: project_task_list.creator_id,
       project_id: project_task_list.project_id,
       project: project_task_list.project,
       workspace: project_task_list.workspace,
       category: project_task_list.category,
       creator: project_task_list.creator
     }}
  end

  defp verify_create({:error, project_task_list}) do
    {:error, extract_changeset_error(project_task_list)}
  end
end
