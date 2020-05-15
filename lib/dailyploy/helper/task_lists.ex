defmodule Dailyploy.Helper.TaskLists do
  alias Dailyploy.Repo
  alias Dailyploy.Model.TaskLists, as: TLModel
  import DailyployWeb.Helpers

  def create(params) do
    %{
      name: name,
      description: description,
      estimation: estimation,
      status: status,
      priority: priority,
      owner_id: owner_id,
      category_id: category_id,
      project_task_list_id: project_task_list_id
    } = params

    verify_create(
      TLModel.create(%{
        name: name,
        description: description,
        estimation: estimation,
        status: status,
        priority: priority,
        owner_id: owner_id,
        category_id: category_id,
        project_task_list_id: project_task_list_id
      })
    )
  end

  defp verify_create({:ok, task_lists}) do
    task_lists = task_lists |> Repo.preload([:owner, :category, :project_task_list])

    {:ok,
     %{
       id: task_lists.id,
       name: task_lists.name,
       description: task_lists.description,
       estimation: task_lists.estimation,
       status: task_lists.status,
       priority: task_lists.priority,
       owner_id: task_lists.owner_id,
       category_id: task_lists.category_id,
       project_task_list_id: task_lists.project_task_list_id,
       owner: task_lists.owner,
       category: task_lists.category,
       project_task_list: task_lists.project_task_list
     }}
  end

  defp verify_create({:error, task_lists}) do
    {:error, extract_changeset_error(task_lists)}
  end
end
