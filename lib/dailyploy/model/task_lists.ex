defmodule Dailyploy.Model.TaskLists do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Model.TaskLists, as: PTModel
  alias Dailyploy.Schema.{TaskLists, UserStories, TaskListTasks}

  def create(params) do
    changeset = TaskLists.changeset(%TaskLists{}, params)

    case Repo.insert(changeset) do
      {:ok, task_lists} ->
        {:ok, task_lists |> Repo.preload([:project, :workspace, :creator, :category])}

      {:error, message} ->
        {:error, message}
    end
  end

  def delete(task_lists) do
    case Repo.delete(task_lists) do
      {:ok, task_lists} ->
        {:ok, task_lists |> Repo.preload([:project, :workspace, :creator, :category])}

      {:error, message} ->
        {:error, message}
    end
  end

  def update(%TaskLists{} = task_lists, params) do
    changeset = TaskLists.changeset(task_lists, params)

    case Repo.update(changeset) do
      {:ok, task_lists} ->
        {:ok, task_lists |> Repo.preload([:project, :workspace, :creator, :category])}

      {:error, message} ->
        {:error, message}
    end
  end

  # def get(id), do: Repo.get(TaskLists, id) |> Repo.preload([:project, :workspace, :creator])

  def get(id) when is_integer(id) do
    case Repo.get(TaskLists, id) do
      nil ->
        {:error, "not found"}

      task_lists ->
        task_lists = task_lists |> Repo.preload([:project, :workspace, :creator, :category])

        {:ok, task_lists}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads, project_id) do
    query =
      from task_list in TaskLists,
        where: task_list.project_id == ^project_id,
        order_by: [desc: task_list.inserted_at]

    task_lists_data = query |> Repo.paginate(page: page_number, page_size: page_size)

    task_lists_with_preloads = task_lists_data.entries |> Repo.preload(preloads)
    paginated_response(task_lists_with_preloads, task_lists_data)
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

  def load_data(task_list, query, params) do
    story_ids = PTModel.fetch_user_story_ids(task_list)
    query2 = PTModel.create_query(story_ids, params)

    task_list
    |> Repo.preload([
      :project,
      :workspace,
      :creator,
      :category,
      task_list_tasks: query,
      user_stories: [:task_status, :owner, :roadmap_checklist, task_lists_tasks: query2]
    ])
  end

  def fetch_user_story_ids(task_list) do
    query =
      from story in UserStories,
        where: story.task_lists_id == ^task_list.id,
        select: story.id

    Repo.all(query)
  end

  def create_query(story_ids, filters) do
    TaskListTasks
    |> where([task_list_task], task_list_task.user_stories_id in ^story_ids)
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

  @doc """
  1. Total Tasks
  2. Total Estimates Hours
  3. Total By Status
  4. Completed Vs Total Tasks
  5. Remaining Hours Vs Assigned Hours
  """
  def summary(task_list) do
    task_list_tasks = collect_tasks(task_list)

    summary =
      task_list_tasks
      |> find_total_tasks()
      |> find_estimate_hours()
      |> completed_tasks()
      |> remaining_hours()

    [total_user_stories, completed_user_stories, user_stories_left] =
      process_user_story(task_list.user_stories)

    Map.put_new(summary, "total_user_stories", total_user_stories)
    |> Map.put_new("completed_user_stories", completed_user_stories)
    |> Map.put_new("user_stories_left", user_stories_left)
  end

  defp process_user_story(story) do
    total_user_stories = length(story)
    completed_user_stories = completed_user_stories(story)
    user_stories_left = total_user_stories - completed_user_stories
    [total_user_stories, completed_user_stories, user_stories_left]
  end

  defp completed_user_stories(stories) do
    Enum.reduce(stories, 0, fn story, acc ->
      case story.is_completed do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  defp collect_tasks(task_list) do
    user_stories_task =
      Enum.reduce(task_list.user_stories, [], fn story, acc ->
        acc ++ story.task_lists_tasks
      end)

    task_list.task_list_tasks ++ user_stories_task
  end

  defp find_total_tasks(task_list_tasks) do
    %{
      "total_tasks" => length(task_list_tasks),
      "task_list_tasks" => task_list_tasks
    }
  end

  defp find_estimate_hours(result) do
    %{"task_list_tasks" => task_list_tasks} = result

    estimated_hours =
      Enum.reduce(task_list_tasks, %{}, fn task, acc ->
        task = task |> Repo.preload([:task_status])

        case task.task_status do
          nil -> acc
          _ -> assemble_map(acc, task)
        end
      end)

    total_estimate_hours =
      Enum.reduce(estimated_hours, 0, fn {_key, value}, acc -> acc + value end)

    result = Map.merge(result, estimated_hours)
    Map.put_new(result, "total_estimate_hours", total_estimate_hours)
  end

  defp assemble_map(acc, task) do
    case Map.has_key?(acc, task.task_status.name) do
      true ->
        previous_estimation = Map.fetch!(acc, task.task_status.name)

        current_estimation =
          case task.estimation do
            nil -> 0
            _ -> task.estimation
          end

        final_estimation = previous_estimation + current_estimation
        Map.replace!(acc, task.task_status.name, final_estimation)

      false ->
        current_estimation =
          case task.estimation do
            nil -> 0
            _ -> task.estimation
          end

        Map.put_new(acc, task.task_status.name, current_estimation)
    end
  end

  defp completed_tasks(%{"task_list_tasks" => task_list_tasks} = result) do
    completed_task =
      Enum.reduce(task_list_tasks, 0, fn task, acc ->
        task = task |> Repo.preload([:task_status])

        case task.task_status do
          nil ->
            acc

          _ ->
            case task.task_status.name == "completed" do
              true -> acc + 1
              false -> acc
            end
        end
      end)

    Map.put_new(result, "completed_task", completed_task)
  end

  defp remaining_hours(
         %{"task_list_tasks" => task_list_tasks, "total_estimate_hours" => total_estimate_hours} =
           result
       ) do
    hours_worked =
      Enum.reduce(task_list_tasks, 0, fn task_list, acc ->
        case task_list.task_id == nil do
          true ->
            acc

          false ->
            task_list = Repo.preload(task_list, task: :time_tracks)

            case List.first(task_list.task.time_tracks) do
              nil -> acc
              _ -> acc + calculate_durations(task_list.task.time_tracks)
            end
        end
      end)

    hours_worked = hours_worked / 3600
    remaining_hours = total_estimate_hours - hours_worked
    result = Map.put_new(result, "remaining_hours", remaining_hours)
    Map.delete(result, "task_list_tasks")
  end

  defp calculate_durations(task_list) when is_nil(task_list) == false do
    Enum.reduce(task_list, 0, fn time_track, acc ->
      case is_nil(time_track.duration) do
        true -> acc
        false -> acc + time_track.duration
      end
    end)
  end
end
