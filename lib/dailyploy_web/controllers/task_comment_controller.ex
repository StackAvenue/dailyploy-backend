defmodule DailyployWeb.TaskCommentController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Helper.TaskComment
  alias Dailyploy.Helper.ImageDeletion
  alias Dailyploy.Helper.CommentsAttachment
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.TaskComment, as: TCModel
  alias Dailyploy.Model.CommentsAttachment, as: CAModel
  alias Dailyploy.Model.Notification, as: NotificationModel
  alias Dailyploy.Avatar

  import DailyployWeb.Validators.TaskComment
  import DailyployWeb.Validators.CommentsAttachment
  import DailyployWeb.Helpers

  plug :load_task_and_user when action in [:create]
  plug :load_comment when action in [:update, :delete, :show]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_task_comment(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, comment}} <- {:create, TaskComment.create_comment(data)} do
          # attachments are needed to be inserted here on
          attachment =
            with true <- Map.has_key?(params, "attachments") do
              insert_attachments(comment, params)
            else
              false -> []
            end

          comment = Map.put_new(comment, :attachment, attachment)

          # Task.async(TaskComment.send_activity_mail(comment)) task notification should be send as mail to the one who is responsible for this
          Task.async(fn ->
            notification_create(comment, "commented")
          end)

          conn
          |> put_status(200)
          |> render("show.json", %{comment: comment})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Either Task or User Not Found")
    end
  end

  def show(conn, params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show.json", %{comment: conn.assigns.comment})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{comment: comment}} = conn

        case TCModel.update_task_comment(comment, params) do
          {:ok, comment} ->
            attachment =
              with true <- Map.has_key?(params, "attachments") do
                update_attachment(comment.attachment)
                insert_attachments(comment, params)
              else
                false ->
                  update_attachment(comment.attachment)
                  []
              end

            comment = Map.replace!(comment, :attachment, attachment)

            conn
            |> put_status(200)
            |> render("show.json", %{comment: comment})

          {:error, comment} ->
            error = extract_changeset_error(comment)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, params) do
    case conn.status do
      nil ->
        case TCModel.delete_task_comment(conn.assigns.comment) do
          {:ok, comment} ->
            with false <- is_nil(List.first(comment.attachment)),
                 do: delete_attachment(comment.attachment)

            conn
            |> put_status(200)
            |> render("show.json", %{comment: comment})

          {:error, comment} ->
            error = extract_changeset_error(comment)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_task_and_user(
         %{params: %{"task_id" => task_id, "user_id" => user_id}} = conn,
         _params
       ) do
    {task_id, _} = Integer.parse(task_id)
    {user_id, _} = Integer.parse(user_id)

    case TaskModel.get(task_id) do
      {:ok, task} ->
        case UserModel.get(user_id) do
          {:ok, user} ->
            assign(conn, :task, task)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_comment(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case TCModel.get(id) do
      nil ->
        conn
        |> put_status(404)

      comment ->
        assign(conn, :comment, comment)
    end
  end

  defp insert_attachments(comment, params) do
    for attachment <- params["attachments"] do
      with {:ok, attachment} <- add_image_url(comment, attachment),
           do: create_attachment(attachment)
    end
  end

  defp add_image_url(comment, image) do
    params = %{}

    with {:ok, image_name} <- Avatar.store({image, "attachments"}) do
      params = Map.put_new(params, "image_url", Avatar.url({image_name, "attachments"}))
      params = Map.put_new(params, "task_comment_id", comment.id)
      {:ok, params}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp create_attachment(attachment) do
    {:ok, changeset} = verify_attachment(attachment) |> extract_changeset_data
    CommentsAttachment.create_attachment(changeset)
  end

  defp delete_attachment(attachments) do
    for attachment <- attachments do
      ImageDeletion.delete_operation(attachment, "attachments")
      # CAModel.delete_attachment(attachment)
    end
  end

  defp update_attachment(attachments) do
    for attachment <- attachments do
      ImageDeletion.delete_operation(attachment, "attachments")
      CAModel.delete_attachment(attachment)
    end
  end

  defp notification_create(comment, type) do
    task = comment.task
    task = task |> Repo.preload([:project])

    Enum.each(task.members, fn member ->
      unless member.id == comment.user.id do
        notification_params(task.name, comment.user, member, task.project, type)
        |> NotificationModel.create()
      end
    end)
  end

  defp notification_params(task_name, owner, member, project, type) do
    %{
      creator_id: owner.id,
      receiver_id: member.id,
      data: %{
        message:
          "#{String.capitalize(owner.name)} has #{type} on your task '#{task_name}' in #{
            String.capitalize(project.name)
          }",
        source: "task_comment"
      }
    }
  end
end
