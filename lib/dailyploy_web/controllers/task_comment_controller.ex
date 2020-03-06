defmodule DailyployWeb.TaskCommentController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Helper.TaskComment
  alias Dailyploy.Helper.CommentsAttachment
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.TaskComment, as: TCModel
  alias Dailyploy.Model.CommentsAttachment, as: CAModel
  import DailyployWeb.Validators.TaskComment
  import DailyployWeb.Validators.CommentsAttachment
  import DailyployWeb.Helpers
  alias Dailyploy.Avatar

  plug :load_task_and_user when action in [:create]
  plug :load_comment when action in [:update]

  def index(conn, params) do
  end

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

          comment = Map.put_new(comment, :attachments, attachment)

          conn
          |> put_status(200)
          |> render("comment.json", %{comment: comment})
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
  end

  def update(conn, params) do
  end

  def delete(conn, params) do
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

  defp load_comment(%{params: %{"id" => id, "task_id" => task_id}} = conn, _params) do
    {id, _} = Integer.parse(id)
    {task_id, _} = Integer.parse(task_id)

    case TCModel.get_comment(id, task_id) do
      {:ok, comment} ->
        assign(conn, :comment, comment)

      {:error, _message} ->
        conn
        |> put_status(404)
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
      params = Map.put_new(params, "comment_id", comment.id)
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
end
