defmodule DailyployWeb.UserStoriesController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.UserStories
  alias Dailyploy.Avatar
  alias Dailyploy.Helper.ImageDeletion
  import DailyployWeb.Validators.UserStories
  import DailyployWeb.Helpers

  plug DailyployWeb.Plug.TaskLists when action in [:create]

  plug DailyployWeb.Plug.UserStories
       when action in [:update, :add_attachments, :show, :delete_attachments]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_user_stories(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, user_stories}} <- {:create, UserStories.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{user_stories: user_stories})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        with {:update, {:ok, user_stories}} <-
               {:update, UserStories.update(conn.assigns.user_stories, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{
            user_stories: user_stories
          })
        else
          {:update, {:error, error}} ->
            send_error(conn, 400, extract_changeset_error(error))
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("user_show.json", %{
          user_stories:
            conn.assigns.user_stories
            |> Dailyploy.Repo.preload([
              :owner,
              :task_status,
              :comments,
              :task_lists_tasks,
              :attachments,
              :roadmap_checklist
            ])
        })

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def add_attachments(conn, params) do
    with true <- Map.has_key?(params, "attachments") do
      result = insert_attachments(conn.assigns.user_stories, params)

      conn
      |> put_status(200)
      |> render("attachment.json", result)
    else
      false -> send_error(conn, 400, "Attachments are not present")
    end
  end

  def delete_attachments(conn, params) do
    with true <- Map.has_key?(params, "attachment_ids") do
      result = delete_attachment(conn.assigns.user_stories, params)

      conn
      |> put_status(200)
      |> render("attachment.json", result)
    else
      false -> send_error(conn, 400, "Attachments are not present")
    end
  end

  def delete_attachment(user_stories, %{"attachment_ids" => attachment_ids}) do
    attachment_ids = attachment_ids |> String.split(",")
    attachments = UserStories.delete_attachments(attachment_ids, user_stories)
    delete_attach(attachments)
  end

  defp delete_attach(attachments) do
    for attachment <- attachments do
      ImageDeletion.delete_operation(attachment, "attachments")
      Dailyploy.Repo.delete(attachment)
    end
  end

  defp insert_attachments(user_stories, params) do
    for attachment <- params["attachments"] do
      with {:ok, attachment} <- add_image_url(user_stories, attachment),
           do: create_attachment(attachment)
    end
  end

  defp add_image_url(user_stories, image) do
    params = %{}

    with {:ok, image_name} <- Avatar.store({image, "attachments"}) do
      params = Map.put_new(params, "image_url", Avatar.url({image_name, "attachments"}))
      params = Map.put_new(params, "user_stories_id", user_stories.id)
      {:ok, params}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp create_attachment(attachment) do
    {:ok, changeset} =
      verify_attachments(attachment)
      |> extract_changeset_data

    changeset =
      Map.from_struct(changeset)
      |> Map.drop([:_id, :__meta__])

    UserStories.create_attachment(changeset)
  end
end
