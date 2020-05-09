defmodule DailyployWeb.TaskController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Schema.Task, as: TaskSchema
  alias Dailyploy.Schema.TaskComment
  alias Dailyploy.Helper.Firebase
  alias Dailyploy.Helper.TaskComment, as: TCHelper
  alias Dailyploy.Helper.SendText
  alias Dailyploy.Model.Notification, as: NotificationModel

  import Ecto.Query

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"project_id" => project_id}) do
    tasks =
      TaskModel.list_tasks(project_id)
      |> Repo.preload([:members, :owner, :category, :time_tracks])

    render(conn, "index.json", tasks: tasks)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project_id" => project_id, "task" => task_params}) do
    user = Guardian.Plug.current_resource(conn)

    task_params =
      task_params
      |> Map.put("project_id", project_id)
      |> Map.put("owner_id", user.id)

    case TaskModel.create_task(task_params) do
      {:ok, %TaskSchema{} = task} ->
        task = task |> Repo.preload([:project, :owner, :category, :time_tracks])

        Firebase.insert_operation(
          Poison.encode(task),
          "task_created/#{conn.params["workspace_id"]}/#{task.id}"
        )

        Task.async(fn ->
          notification_create(task, "created")
        end)

        params = %{
          task_id: task.id,
          user_id: user.id,
          comments: "#{user.name} has created #{task.name} task."
        }

        TCHelper.create_comment(params)

        date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
        task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)

        render(conn, "show.json", task: task)

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = TaskModel.get_task!(id)

    case TaskModel.update_task_status(task, task_params) do
      {:ok, %TaskSchema{} = task} ->
        task = task |> Repo.preload([:project, :owner, :category, :time_tracks])

        Firebase.insert_operation(
          Poison.encode(task),
          "task_update/#{conn.params["workspace_id"]}/#{task.id}"
        )

        Task.async(fn ->
          notification_create(task, "updated")
        end)

        date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
        task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)

        render(conn, "show.json", task: task)

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def task_completion(conn, %{"id" => id, "task" => task_params}) do
    task = TaskModel.get_task!(id)

    case TaskModel.mark_task_complete(task, task_params) do
      {:ok, %TaskSchema{} = task} ->
        Firebase.insert_operation(
          Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
          "task_completed/#{conn.params["workspace_id"]}/#{task.id}"
        )

        with true <- Map.has_key?(task_params, "contact_ids"),
             do: fetch_contacts(task, task_params["contact_ids"])

        task = task |> Repo.preload([:owner, :category, :time_tracks])
        date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
        task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)
        render(conn, "show.json", task: task)

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  defp fetch_contacts(task, contact_ids) do
    task = Repo.preload(task, project: :contacts)
    contact_ids = contact_ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    Enum.each(contact_ids, fn contact_id ->
      check_contact(task, task.project.contacts, contact_id)
    end)
  end

  defp check_contact(task, contacts, contact_id) do
    Enum.each(contacts, fn contact ->
      if(contact.id === contact_id and !is_nil(contact.phone_number)) do
        SendText.text_operation(
          "Task with name #{task.name} is been completed",
          contact.phone_number
        )
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    query = from task_comment in TaskComment, order_by: [desc: task_comment.inserted_at]
    # , :task_comments, task_comments: [:attachment, :user]]
    task =
      TaskModel.get_task!(id)
      |> Repo.preload(task_comments: query)
      |> Repo.preload([
        :members,
        :owner,
        :category,
        :time_tracks,
        task_comments: [:attachment, :user]
      ])

    # task = task |> Repo.preload(task_comments: {query})
    date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
    task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)
    task = Repo.preload(task, project: :contacts)
    render(conn, "task_with_user_show.json", task: task)
  end

  # defp comments_query() do
  #   from c in TaskComment, order_by: c.inserted_at
  # end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    task = TaskModel.get_task!(id)

    task_copy = task |> Repo.preload([:members, :project])

    with false <- is_nil(task) do
      if user.id == task.owner_id do
        case TaskModel.delete_task(task) do
          {:ok, %TaskSchema{} = task} ->
            Firebase.insert_operation(
              Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
              "task_deleted/#{conn.params["workspace_id"]}/#{task.id}"
            )

            Task.async(fn ->
              notification_create(task_copy, "deleted")
            end)

            render(conn, "deleted_task.json", task: task |> Repo.preload([:owner]))

          {:error, task} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{errors: task.errors})
        end
      else
        conn
        |> put_status(403)
        |> json(%{"task_owner" => false})
      end
    else
      true ->
        conn
        |> put_status(404)
        |> json(%{"resource_not_found" => true})
    end
  end

  def running_task(conn, %{"workspace_id" => workspace_id} = params) do
    %{id: user_id} = Guardian.Plug.current_resource(conn)

    case TaskModel.running_task(%{user_id: user_id, workspace_id: workspace_id}) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{"resource_not_found" => true})

      time_track ->
        conn
        |> put_status(200)
        |> render("task_running.json",
          time_track:
            time_track
            |> Repo.preload(
              task: [:members, :owner, :time_tracks, :category, :project, :task_comments]
            )
        )
    end
  end

  defp date_wise_orientation(task_list) do
    Enum.reduce(task_list, %{}, fn time_track, acc ->
      case Map.has_key?(acc, Date.to_iso8601(time_track.start_time)) do
        true ->
          time_track_add = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          acc = Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_add)

        false ->
          acc = Map.put_new(acc, Date.to_iso8601(time_track.start_time), [])
          time_track_new = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          acc = Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_new)
      end
    end)
  end

  defp notification_create(%TaskSchema{} = task, type) do
    Enum.each(task.members, fn member ->
      unless member.id == task.owner.id do
        notification_parameters = notification_params(task.name, task.owner, member, task.project, type)
        notification_parameters |> NotificationModel.create()

        Firebase.insert_operation(
          Poison.encode(notification_parameters),
          "notification/#{task.project.workspace_id}/#{member.id}"
        )
      end
    end)
  end

  defp notification_params(task_name, owner, member, project, type) do
    %{
      creator_id: owner.id,
      receiver_id: member.id,
      data: %{
        message:
          "#{String.capitalize(owner.name)} has #{type} a task '#{task_name}' for you in #{
            String.capitalize(project.name)
          }",
        source: "task"
      }
    }
  end
end
