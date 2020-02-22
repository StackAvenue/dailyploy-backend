defmodule Dailyploy.Model.Task do
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserTask
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Model.TimeTracking, as: TTModel
  alias Dailyploy.Model.Task, as: TaskModel

  def list_tasks(project_id) do
    query =
      from(task in Task,
        where: task.project_id == ^project_id,
        order_by: task.inserted_at
      )

    Repo.all(query)
  end

  def list_workspace_tasks(workspace_id) do
    project_query =
      from(project in Project, where: project.workspace_id == ^workspace_id, select: project.id)

    project_ids = Repo.all(project_query)

    task_query = from(task in Task, where: task.project_id in ^project_ids)
    Repo.all(task_query)
  end

  def list_workspace_user_tasks(workspace_id, user_id) do
    query =
      from task in Task,
        join: project in Project,
        on: task.project_id == project.id,
        where: project.workspace_id == ^workspace_id

    User
    |> Repo.get(user_id)
    |> Repo.preload(tasks: query)
    |> Map.fetch!(:tasks)
  end

  def list_workspace_user_tasks(params) do
    query =
      Task
      |> join(:inner, [task], project in Project, on: project.id == task.project_id)
      |> join(:inner, [task], user_task in UserTask, on: task.id == user_task.task_id)
      |> join(:left, [task], time_track in TimeTracking, on: time_track.task_id == task.id)
      |> where(^filter_for_tasks_for_criteria(params))
      |> distinct(true)

    Repo.all(query)
  end

  def get_details_of_task(user_workspace_setting_id, project_id) do
    query =
      from(task in Task,
        join: project in Project,
        on: task.project_id == ^project_id,
        join: userworkspacesettings in UserWorkspaceSetting,
        on:
          userworkspacesettings.id == ^user_workspace_setting_id and
            project.owner_id == userworkspacesettings.user_id
      )

    List.first(Repo.all(query))
  end

  def get_task!(id), do: Repo.get(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(task, attrs) do
    task
    |> Task.update_changeset(attrs)
    |> Repo.update()
  end

  def update_task_status(task, attrs) do
    task
    |> Task.update_status_changeset(attrs)
    |> Repo.update()
  end

  def mark_task_complete(task, attrs) do
    time_tracks = TTModel.find_with_task_id(task.id)

    case is_nil(time_tracks) do
      true ->
        task =
          task
          |> Task.update_status_changeset(attrs)
          |> Repo.update()

        with {:ok, _time_tracks} <- TTModel.create_logged_task(task) do
          task
        end

      false ->
        task
        |> Task.update_status_changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_task(task) do
    Repo.delete(task)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Task, id) do
      nil ->
        {:error, "not found"}

      task ->
        {:ok, task}
    end
  end

  def get(ids, preloads) do
    query =
      from(task in Task,
        where: task.id in ^ids
      )

    Repo.all(query) |> Repo.preload(preloads)
  end

  def get_tasks(ids) do
    query =
      from(task in Task,
        where: task.id in ^ids
      )

    Repo.all(query)
  end

  def tracked_time(task_id) do
    case TaskModel.get(task_id) do
      {:error, _message} ->
        0

      {:ok, task} ->
        query =
          from(tracked_time in TimeTracking,
            where: tracked_time.task_id == ^task.id,
            select: sum(tracked_time.duration)
          )

        result = Repo.one(query)

        case is_nil(result) do
          true -> 0
          false -> result
        end
    end
  end

  def tracked_time(task_id, start_date, end_date) do
    case TaskModel.get(task_id) do
      {:error, _message} ->
        0

      {:ok, task} ->
        query =
          from(tracked_time in TimeTracking,
            where:
              tracked_time.task_id == ^task.id and
                (fragment(
                   "?::date BETWEEN ? AND ?",
                   tracked_time.start_time,
                   ^start_date,
                   ^end_date
                 ) or
                   fragment(
                     "?::date BETWEEN ? AND ?",
                     tracked_time.end_time,
                     ^start_date,
                     ^end_date
                   ) or
                   fragment(
                     "?::date <= ? AND ?::date >= ?",
                     tracked_time.start_time,
                     ^start_date,
                     tracked_time.end_time,
                     ^end_date
                   )),
            select: sum(tracked_time.duration)
          )

        result = Repo.one(query)

        case is_nil(result) do
          true -> 0
          false -> result
        end
    end
  end

  def project_summary_report_data(task_ids) do
    tasks = get(task_ids, [:project, :time_tracks])

    Enum.reduce(tasks, [], fn task, category_acc ->
      category_data = Enum.find(category_acc, fn map -> map["id"] == task.project_id end)

      case category_data do
        nil ->
          category_acc =
            category_acc ++
              [
                %{
                  "id" => task.project_id,
                  "name" => task.project.name,
                  "tracked_time" => tracked_time(task.id)
                }
              ]

        _ ->
          updated_category_data =
            Map.put(
              category_data,
              "tracked_time",
              category_data["tracked_time"] + tracked_time(task.id)
            )

          category_acc = category_acc -- [category_data]
          category_acc = category_acc ++ [updated_category_data]
      end
    end)
  end

  def project_summary_report_data(
        task_ids,
        %{"end_date" => end_date, "start_date" => start_date} = params
      ) do
    tasks = get(task_ids, [:project, :time_tracks])

    Enum.reduce(tasks, [], fn task, category_acc ->
      category_data = Enum.find(category_acc, fn map -> map["id"] == task.project_id end)

      case category_data do
        nil ->
          category_acc =
            category_acc ++
              [
                %{
                  "id" => task.project_id,
                  "name" => task.project.name,
                  "tracked_time" => tracked_time(task.id, start_date, end_date)
                }
              ]

        _ ->
          updated_category_data =
            Map.put(
              category_data,
              "tracked_time",
              category_data["tracked_time"] + tracked_time(task.id, start_date, end_date)
            )

          category_acc = category_acc -- [category_data]
          category_acc = category_acc ++ [updated_category_data]
      end
    end)
  end

  def user_summary_report_data(
        task_ids,
        %{"end_date" => end_date, "start_date" => start_date} = params
      ) do
    tasks = get(task_ids, [:members])

    Enum.reduce(tasks, 0, fn task, total_tracked_time ->
      total_tracked_time + tracked_time(task.id, start_date, end_date)
    end)
  end

  def category_summary_report_data(
        task_ids,
        %{"end_date" => end_date, "start_date" => start_date} = params
      ) do
    tasks = get(task_ids, [:category])

    Enum.reduce(tasks, [], fn task, category_acc ->
      category_data = Enum.find(category_acc, fn map -> map["id"] == task.category_id end)

      case category_data do
        nil ->
          category_acc =
            category_acc ++
              [
                %{
                  "id" => task.category_id,
                  "name" => task.category.name,
                  "tracked_time" => tracked_time(task.id, start_date, end_date)
                }
              ]

        _ ->
          updated_category_data =
            Map.put(
              category_data,
              "tracked_time",
              category_data["tracked_time"] + tracked_time(task.id, start_date, end_date)
            )

          category_acc = category_acc -- [category_data]
          category_acc = category_acc ++ [updated_category_data]
      end
    end)
  end

  def priority_summary_report_data(%{"end_date" => end_date, "start_date" => start_date} = params) do
    task_ids = TaskModel.task_ids_for_criteria(params)
    total_estimated_time = TaskModel.total_estimated_time(task_ids, params)
    tasks = get_tasks(task_ids)

    report_data =
      Enum.reduce(tasks, [], fn task, priority_acc ->
        priority_data = Enum.find(priority_acc, fn map -> map["priority"] == task.priority end)

        case priority_data do
          nil ->
            priority_acc =
              priority_acc ++
                [
                  %{
                    "priority" => task.priority,
                    "tracked_time" => tracked_time(task.id, start_date, end_date)
                  }
                ]

          _ ->
            updated_priority_data =
              Map.put(
                priority_data,
                "tracked_time",
                priority_data["tracked_time"] + tracked_time(task.id, start_date, end_date)
              )

            priority_acc = priority_acc -- [priority_data]
            priority_acc = priority_acc ++ [updated_priority_data]
        end
      end)

    %{total_estimated_time: total_estimated_time, report_data: report_data}
  end

  def total_estimated_time(task_ids) do
    query =
      from(task in Task,
        where:
          task.id in ^task_ids and
            (is_nil(task.start_datetime) == false and is_nil(task.end_datetime) == false),
        select:
          fragment("SUM(EXTRACT(EPOCH FROM ((?) - (?))))", task.end_datetime, task.start_datetime)
      )

    Repo.one(query)
  end

  def total_estimated_time(
        task_ids,
        %{"end_date" => end_date, "start_date" => start_date} = params
      ) do
    query =
      from(task in Task,
        where:
          task.id in ^task_ids and
            (is_nil(task.start_datetime) == false and is_nil(task.end_datetime) == false)
        # select:
        #   fragment("SUM(EXTRACT(EPOCH FROM ((?) - (?))))", task.end_datetime, task.start_datetime)
      )

    tasks = Repo.all(query)

    total_estimated_time =
      Date.range(start_date, end_date)
      |> Enum.reduce(0, fn date, time_acc ->
        time_acc =
          time_acc +
            Enum.reduce(tasks, 0, fn task, acc ->
              case Date.diff(date, task.start_datetime) == 0 and
                     Date.diff(date, task.end_datetime) == 0 do
                true ->
                  acc + DateTime.diff(task.end_datetime, task.start_datetime)

                false ->
                  case Date.diff(date, task.start_datetime) > 0 and
                         Date.diff(date, task.end_datetime) < 0 do
                    true ->
                      acc + 86400

                    false ->
                      with true <-
                             (Date.diff(date, task.start_datetime) < 0 and
                                Date.diff(date, task.end_datetime) < 0) or
                               (Date.diff(date, task.start_datetime) > 0 and
                                  Date.diff(date, task.end_datetime) > 0) do
                        acc
                      else
                        false ->
                          case Date.diff(date, task.start_datetime) == 0 and
                                 Date.diff(date, task.end_datetime) < 0 do
                            true ->
                              acc +
                                DateTime.diff(
                                  Timex.end_of_day(Timex.to_datetime(date)),
                                  task.start_datetime
                                )

                            false ->
                              case Date.diff(date, task.start_datetime) > 0 and
                                     Date.diff(date, task.end_datetime) == 0 do
                                true ->
                                  acc +
                                    DateTime.diff(
                                      task.end_datetime,
                                      Timex.beginning_of_day(Timex.to_datetime(date))
                                    )

                                false ->
                                  acc
                              end
                          end
                      end
                  end
              end
            end)
      end)
  end

  def task_ids_for_criteria(params) do
    query =
      Task
      |> join(:inner, [task], project in Project, on: project.id == task.project_id)
      |> join(:inner, [task], user_task in UserTask, on: task.id == user_task.task_id)
      |> join(:left, [task], time_track in TimeTracking, on: time_track.task_id == task.id)
      |> where(^filter_for_tasks_for_criteria(params))
      |> distinct(true)

    Enum.map(Repo.all(query), fn task -> task.id end)
  end

  defp filter_for_tasks_for_criteria(params) do
    Enum.reduce(params, dynamic(true), fn
      {"workspace_id", workspace_id}, dynamic_query ->
        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and project.workspace_id == ^workspace_id
        )

      {"user_ids", user_ids}, dynamic_query ->
        user_ids = Enum.map(String.split(user_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and user_task.user_id in ^user_ids
        )

      {"project_ids", project_ids}, dynamic_query ->
        project_ids = Enum.map(String.split(project_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and task.project_id in ^project_ids
        )

      {"category_ids", category_ids}, dynamic_query ->
        category_ids = Enum.map(String.split(category_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and task.category_id in ^category_ids
        )

      {"priorities", priorities}, dynamic_query ->
        priorities = Enum.map(String.split(priorities, ","), fn x -> x end)

        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and task.priority in ^priorities
        )

      {"start_date", start_date}, dynamic_query ->
        end_date = params["end_date"]

        dynamic(
          [task, project, user_task, time_track],
          ^dynamic_query and
            (fragment("?::date BETWEEN ? AND ?", task.start_datetime, ^start_date, ^end_date) or
               fragment("?::date BETWEEN ? AND ?", task.end_datetime, ^start_date, ^end_date) or
               fragment(
                 "?::date <= ? AND ?::date >= ?",
                 task.start_datetime,
                 ^start_date,
                 task.end_datetime,
                 ^end_date
               ) or
               fragment(
                 "?::date BETWEEN ? AND ?",
                 time_track.start_time,
                 ^start_date,
                 ^end_date
               ) or
               fragment(
                 "?::date BETWEEN ? AND ?",
                 time_track.end_time,
                 ^start_date,
                 ^end_date
               ) or
               fragment(
                 "?::date <= ? AND ?::date >= ?",
                 time_track.start_time,
                 ^start_date,
                 time_track.end_time,
                 ^end_date
               ))
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"workspace_id", workspace_id}, dynamic ->
        dynamic([task, project], ^dynamic and project.workspace_id == ^workspace_id)

      {"project_ids", project_ids}, dynamic ->
        project_ids =
          project_ids
          |> String.split(",")
          |> Enum.map(fn project_id -> String.trim(project_id) end)

        dynamic([task], ^dynamic and task.project_id in ^project_ids)

      {"category_ids", category_ids}, dynamic ->
        category_ids =
          category_ids
          |> String.split(",")
          |> Enum.map(fn category_id -> String.trim(category_id) end)

        dynamic([task, project], ^dynamic and task.category_id in ^category_ids)

      {"priority", priority}, dynamic ->
        dynamic([task, priority], ^dynamic and task.priority == ^priority)

      {"start_date", start_date}, dynamic ->
        end_date = params["end_date"]

        dynamic(
          [task],
          ^dynamic and
            (fragment("?::date BETWEEN ? AND ?", task.start_datetime, ^start_date, ^end_date) or
               fragment("?::date BETWEEN ? AND ?", task.end_datetime, ^start_date, ^end_date) or
               fragment(
                 "?::date <= ? AND ?::date >= ?",
                 task.start_datetime,
                 ^start_date,
                 task.end_datetime,
                 ^end_date
               ))
        )

      {"user_ids", user_ids}, dynamic ->
        user_ids =
          user_ids
          |> String.split(",")
          |> Enum.map(fn user_id -> String.trim(user_id) end)

        dynamic([task, project], ^dynamic and task.owner_id in ^user_ids)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
