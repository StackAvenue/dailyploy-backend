defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller

  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.TimeTracking

  plug Auth.Pipeline
  plug :put_view, DailyployWeb.UserView when action in [:user_tasks]
  plug :put_view, DailyployWeb.TaskView when action in [:project_tasks]

  action_fallback DailyployWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    workspace_admin_query = UserModel.get_admin_user_query()

    workspaces =
      WorkspaceModel.all_user_workspaces(user)
      |> Repo.preload([:company, users: workspace_admin_query])

    render(conn, "index.json", workspaces: workspaces)
  end

  def user_tasks(conn, %{
        "workspace_id" => workspace_id,
        "frequency" => frequency,
        "start_date" => start_date
      }) do
    query_params = map_to_atom(conn.query_params)

    {:ok, start_date} =
      start_date
      |> Date.from_iso8601()

    end_date =
      case frequency do
        "daily" ->
          start_date

        "weekly" ->
          Date.add(start_date, 6)

        "monthly" ->
          days = Date.days_in_month(start_date)
          Date.add(start_date, days - 1)
      end

    current_time = Date.utc_today()

    query =
      case is_nil(String.first(query_params.project_ids)) do
        true ->
          from task in Task,
            join: project in Project,
            on: task.project_id == project.id,
            left_join: time_track in TimeTracking,
            on: time_track.task_id == task.id,
            where:
              project.workspace_id == ^workspace_id and
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
                   )),
            distinct: task.id

        false ->
          project_ids =
            Enum.map(String.split(query_params.project_ids, ","), fn x -> String.to_integer(x) end)

          from task in Task,
            join: project in Project,
            on: task.project_id == project.id and task.project_id in ^project_ids,
            left_join: time_track in TimeTracking,
            on: time_track.task_id == task.id,
            where:
              project.workspace_id == ^workspace_id and
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
                   )),
            distinct: task.id
      end

    users =
      case is_nil(String.first(query_params.user_id)) do
        true ->
          UserModel.list_users(workspace_id) |> Repo.preload(tasks: {query, project: [:members]})

        false ->
          user_ids =
            Enum.map(String.split(query_params.user_id, ","), fn x -> String.to_integer(x) end)

          UserModel.list_users(workspace_id, user_ids)
          |> Repo.preload(tasks: {query, project: [:members]})
      end

    users = users |> Repo.preload(tasks: :time_tracks)

    users =
      Enum.map(users, fn user ->
        date_formatted_tasks =
          user.tasks
          |> Enum.reduce(%{}, fn task, acc ->
            [range_end_date, range_start_date] =
              if(Enum.empty?(task.time_tracks)) do
                range_end_date = smaller_date(DateTime.to_date(task.end_datetime), end_date)
                range_start_date = greater_date(DateTime.to_date(task.start_datetime), start_date)
                [range_end_date, range_start_date]
              else
                first_time_track = task.time_tracks |> List.first()
                last_time_track = task.time_tracks |> List.last()

                task_start_date =
                  smaller_date(task.start_datetime, first_time_track.start_time)
                  |> DateTime.to_date()

                task_end_date =
                  greater_date(task.end_datetime, last_time_track.start_time)
                  |> DateTime.to_date()

                range_start_date = smaller_date(task_start_date, end_date)
                range_end_date = greater_date(task_end_date, start_date)
                [range_end_date, range_start_date]
              end

            date_formatted_time_tracks =
              Enum.reduce(task.time_tracks, %{}, fn time_track, time_acc ->
                time_track_range_start_date =
                  greater_date(DateTime.to_date(time_track.start_time), start_date)

                time_track_range_end_date =
                  case is_nil(time_track.end_time) do
                    true -> time_track_range_start_date
                    false -> smaller_date(DateTime.to_date(time_track.end_time), end_date)
                  end

                time_track_range_start_date
                |> Date.range(time_track_range_end_date)
                |> Enum.reduce(time_acc, fn date, date_acc ->
                  time_track =
                    case Map.has_key?(date_acc, Date.to_iso8601(date)) do
                      true ->
                        Map.get(date_acc, Date.to_iso8601(date)) ++ [time_track]

                      false ->
                        date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])
                        Map.get(date_acc, Date.to_iso8601(date)) ++ [time_track]
                    end

                  Map.put(date_acc, Date.to_iso8601(date), time_track)
                end)
              end)

            task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)

            range_start_date
            |> Date.range(range_end_date)
            |> Enum.reduce(acc, fn date, date_acc ->
              date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])

              is_time_track_present =
                task.time_tracks
                |> Enum.map(fn x ->
                  time_track_date = DateTime.to_date(x.start_time)

                  if(Date.diff(time_track_date, date) === 0) do
                    true
                  end
                end)

              if(
                Enum.member?(is_time_track_present, true) or
                  Date.diff(task.start_datetime, date) === 0 or
                  Enum.empty?(task.time_tracks) or
                  (Date.diff(range_end_date, task.end_datetime) >= 0 and
                     Date.diff(range_start_date, task.start_datetime) <= 0 and
                     Enum.member?(
                       Date.range(
                         DateTime.to_date(task.start_datetime),
                         DateTime.to_date(task.end_datetime)
                       ),
                       date
                     ))
              ) do
                tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
                Map.put(date_acc, Date.to_iso8601(date), tasks)
              else
                date_acc
              end
            end)
          end)

        Map.put(user, :tasks, date_formatted_tasks)
      end)

    render(conn, "user_tasks_index.json", users: users)
  end

  def project_tasks(conn, %{"workspace_id" => workspace_id}) do
    tasks = TaskModel.list_workspace_tasks(workspace_id) |> Repo.preload([:owner, :members])
    render(conn, "index.json", tasks: tasks)
  end

  defp greater_date(date1, date2) do
    case Date.compare(date1, date2) do
      :lt -> date2
      _ -> date1
    end
  end

  defp smaller_date(date1, date2) do
    case Date.compare(date1, date2) do
      :lt -> date1
      _ -> date2
    end
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end
end
