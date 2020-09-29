defmodule Dailyploy.Helper.TaskListTasks do
  alias Dailyploy.Repo
  alias Dailyploy.Model.TaskListTasks, as: TLModel
  import DailyployWeb.Helpers

  def create(params) do
    %{
      name: name,
      description: description,
      estimation: estimation,
      status: status,
      priority: priority,
      owner_id: owner_id,
      task_status_id: task_status_id,
      category_id: category_id,
      task_lists_id: task_lists_id,
      user_stories_id: user_stories_id
    } = params

    verify_create(
      TLModel.create(%{
        name: name,
        description: description,
        estimation: estimation,
        status: status,
        user_stories_id: user_stories_id,
        priority: priority,
        task_status_id: task_status_id,
        owner_id: owner_id,
        category_id: category_id,
        task_lists_id: task_lists_id
      })
    )
  end

  defp verify_create({:ok, task_list_tasks}) do
    task_list_tasks =
      task_list_tasks |> Repo.preload([:owner, :category, :task_lists, :task_status, :checklist])

    {:ok,
     %{
       id: task_list_tasks.id,
       name: task_list_tasks.name,
       description: task_list_tasks.description,
       estimation: task_list_tasks.estimation,
       status: task_list_tasks.status,
       task_status: task_list_tasks.task_status,
       checklist: task_list_tasks.checklist,
       priority: task_list_tasks.priority,
       owner_id: task_list_tasks.owner_id,
       task_id: task_list_tasks.task_id,
       category_id: task_list_tasks.category_id,
       task_lists_id: task_list_tasks.task_lists_id,
       owner: task_list_tasks.owner,
       category: task_list_tasks.category,
       task_lists: task_list_tasks.task_lists
     }}
  end

  defp verify_create({:error, task_list_tasks}) do
    {:error, extract_changeset_error(task_list_tasks)}
  end
end
