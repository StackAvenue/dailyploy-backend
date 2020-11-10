defmodule Dailyploy.Model.TaskListTasks do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskListTasks
  alias Dailyploy.Schema.UserTask
  alias Dailyploy.Model.TaskListTasks, as: TLTModel
  alias Dailyploy.Model.Task

  def create(params) do
    changeset = TaskListTasks.changeset(%TaskListTasks{}, params)
    Repo.insert(changeset)
  end

  def delete(task_list_tasks) do
    Repo.delete(task_list_tasks)
  end

  def update(%TaskListTasks{} = task_list_tasks, params) do
    case task_list_tasks.task_id do
      nil ->
        changeset = TaskListTasks.changeset(task_list_tasks, params)
        Repo.update(changeset)

      _id ->
        task_list_tasks = Repo.preload(task_list_tasks, [:task])
        Task.update_task_list(task_list_tasks.task, params)
        changeset = TaskListTasks.changeset(task_list_tasks, params)
        Repo.update(changeset)
    end
  end

  def update_task_list(%TaskListTasks{} = task_list_tasks, params) do
    changeset = TaskListTasks.changeset(task_list_tasks, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskListTasks, id) |> Repo.preload([:owner, :category, :project_task_list])

  def get(id) when is_integer(id) do
    case Repo.get(TaskListTasks, id) do
      nil ->
        {:error, "not found"}

      task_list_tasks ->
        {:ok,
         task_list_tasks |> Repo.preload([:owner, :category, :task_lists, :task, :checklist])}
    end
  end

  def move_task(task_list, params) do
    {:ok, task_list} = TLTModel.update(task_list, params)

    case Task.create_task_list(Map.from_struct(task_list) |> extract_params(params)) do
      {:ok, task} ->
        insert_into_user_tasks(task_list.owner_id, task.id)
        TLTModel.update(task_list, %{task_id: task.id})

      {:error, error} ->
        {:error, error}
    end
  end

  defp extract_params(params, dates) do
    %{
      name: params.name,
      start_datetime: dates["start_datetime"],
      end_datetime: dates["end_datetime"],
      task_list_tasks_id: params.id,
      project_id: dates["project_id"],
      owner_id: params.owner_id,
      category_id: params.category_id,
      task_status_id: params.task_status_id,
      estimation: params.estimation,
      priority: params.priority,
      time_tracked: []
    }
  end

  defp insert_into_user_tasks(user_id, task_id) do
    params = %{user_id: user_id, task_id: task_id}
    changeset = UserTask.changeset(%UserTask{}, params)
    Repo.insert(changeset)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads, task_lists_id, filters) do
    query = TLTModel.create_query(task_lists_id, filters)

    task_lists_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    task_lists_with_preloads = task_lists_data.entries |> Repo.preload(preloads)
    paginated_response(task_lists_with_preloads, task_lists_data)
  end

  def create_query(task_lists_id, filters) do
    TaskListTasks
    |> where([task_list_task], task_list_task.task_lists_id == ^task_lists_id)
    |> where(^filter_where(filters))
  end

  def create_query_user_story(user_story_id, filters) do
    TaskListTasks
    |> where([task_list_task], task_list_task.user_stories_id == ^user_story_id)
    |> where(^filter_where(filters))
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"status_ids", status_ids}, dynamic_query ->
        status_ids =
          status_ids
          |> String.split(",")
          |> Enum.map(fn status_id -> String.trim(status_id) end)

        dynamic(
          [task_list_task],
          ^dynamic_query and task_list_task.task_status_id in ^status_ids
        )

      {"member_ids", member_ids}, dynamic_query ->
        member_ids =
          member_ids
          |> String.split(",")
          |> Enum.map(fn member_id -> String.trim(member_id) end)

        dynamic(
          [task_list_task],
          ^dynamic_query and task_list_task.owner_id in ^member_ids
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  defp paginated_response(data, pagination_data) do
    %{
      entries: data,
      page_number: pagination_data.page_number,
      page_size: pagination_data.page_size,
      total_entries: pagination_data.total_entries,
      total_pages: pagination_data.total_pages
    }
  end
end
