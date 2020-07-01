defmodule Dailyploy.Model.TaskStatus do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.{TaskStatus, Project}

  def create(attrs \\ %{}) do
    %TaskStatus{}
    |> TaskStatus.changeset(attrs)
    |> Repo.insert()
  end

  def update(task_category, params) do
    changeset = TaskStatus.changeset(task_category, params)
    Repo.update(changeset)
  end

  def delete(task_category) do
    Repo.delete(task_category)
  end

  def get(id) when is_integer(id) do
    case Repo.get(TaskStatus, id) do
      nil ->
        {:error, "not found"}

      task_status ->
        task_status = task_status |> Repo.preload([:workspace, :project])
        {:ok, task_status}
    end
  end

  def get_running_status(project_id, workspace_id, status) do
    query =
      from task_status in TaskStatus,
        join: project in Project,
        on: project.id == ^project_id and project.workspace_id == ^workspace_id,
        where: task_status.project_id == ^project_id and task_status.name == ^status

    List.first(Repo.all(query))
  end

  def get_all(params, preloads) do
    %{
      page_size: page_size,
      page_number: page_number,
      project_id: project_id,
      workspace_id: workspace_id
    } = params

    query =
      from task_status in TaskStatus,
        join: project in Project,
        on: project.id == ^project_id and project.workspace_id == ^workspace_id,
        where:
          task_status.project_id == ^project_id and task_status.workspace_id == ^workspace_id,
        order_by: task_status.id

    paginated_task_status_data = Repo.paginate(query, page: page_number, page_size: page_size)
    task_status_data_with_preloads = paginated_task_status_data.entries |> Repo.preload(preloads)
    paginated_response(task_status_data_with_preloads, paginated_task_status_data)
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
