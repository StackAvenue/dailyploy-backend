defmodule Dailyploy.Model.TaskStatus do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.{TaskStatus, Project}
  alias Dailyploy.Model.TaskStatus, as: TSModel

  def create(attrs \\ %{}) do
    %TaskStatus{}
    |> TaskStatus.changeset(attrs)
    |> Repo.insert()
  end

  def update(task_status, params) do
    changeset = TaskStatus.changeset(task_status, params)
    Repo.update(changeset)
  end

  def delete(task_status) do
    changeset = TaskStatus.changeset(task_status, %{})

    case task_status.name == "not_started" do
      true ->
        {:error,
         Ecto.Changeset.add_error(changeset, :default_status, "Default status cannot be updated")}

      false ->
        changeset = TaskStatus.delete_changeset(task_status)

        case Repo.delete(changeset) do
          {:ok, task_status} ->
            update_sequence_when_deleted(task_status)
            {:ok, task_status}

          {:error, error} ->
            {:error, error}
        end
    end
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
        order_by: task_status.sequence_no

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

  def update_sequence(update_status, updated, params) do
    previous = update_status.sequence_no

    if updated > previous do
      query =
        from status in TaskStatus,
          where:
            fragment("sequence_no <= ? AND sequence_no > ?", ^updated, ^previous) and
              status.project_id == ^update_status.project_id and
              status.workspace_id == ^update_status.workspace_id

      Repo.update_all(query, inc: [sequence_no: -1])
      TSModel.update(update_status, %{sequence_no: updated})
    else
      if updated < previous do
        query =
          from status in TaskStatus,
            where:
              fragment("sequence_no < ? AND sequence_no >= ?", ^previous, ^updated) and
                status.project_id == ^update_status.project_id and
                status.workspace_id == ^update_status.workspace_id

        Repo.update_all(query, inc: [sequence_no: 1])
        TSModel.update(update_status, %{sequence_no: updated})
      else
        :no_reply
      end
    end

    query =
      from task_status in TaskStatus,
        join: project in Project,
        on:
          project.id == ^params["project_id"] and project.workspace_id == ^params["workspace_id"],
        where:
          task_status.project_id == ^params["project_id"] and
            task_status.workspace_id == ^params["workspace_id"],
        order_by: task_status.sequence_no

    task_status = Repo.all(query) |> Repo.preload([:project, :workspace])
    {:ok, task_status}
  end

  def get_status_ids_in_workspace!(workspace_id) do
    query =
      from task_status in TaskStatus,
        where: task_status.workspace_id == ^workspace_id,
        select: task_status.id,
        distinct: true

    Repo.all(query)
  end

  def update_sequence_when_deleted(task_status) do
    query =
      from status in TaskStatus,
        where:
          status.project_id == ^task_status.project_id and
            status.workspace_id == ^task_status.workspace_id and
            fragment("sequence_no > ? ", ^task_status.sequence_no)

    Repo.update_all(query, inc: [sequence_no: -1])
  end
end
