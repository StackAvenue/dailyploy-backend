defmodule DailyployWeb.NotificationsController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Notification, as: NotificationModel
  import DailyployWeb.Helpers

  plug Auth.Pipeline
  plug :fetch_notification when action in [:mark_as_read]

  action_fallback DailyployWeb.FallbackController

  def index(conn, %{"user_id" => user_id} = params) do
    case conn.status do
      nil ->
        {:list, notifications} = {:list, NotificationModel.get_unreads(user_id)}

        conn
        |> put_status(200)
        |> render("index.json", %{notifications: notifications})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def mark_as_read(conn, _params) do
    case conn.status do
      nil ->
        notification = conn.assigns.notification

        with {:update, {:ok, res}} <-
               {:update, NotificationModel.update(notification, %{read: true})} do
          conn
          |> put_status(200)
          |> render("notification_details.json", %{notifications: res})
        else
          {:update, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def mark_all_as_read(%{params: %{"notification_ids" => notification_ids}} = conn, _params) do
    {:ok, notifications} = NotificationModel.mark_all_as_read(notification_ids)

    conn
    |> put_status(200)
    |> render("index.json", %{notifications: notifications})
  end

  defp fetch_notification(%{params: %{"id" => notification_id}} = conn, _params) do
    notification = NotificationModel.get(notification_id)

    with false <- is_nil(notification) do
      assign(notification, :user, notification)
    else
      true ->
        conn
        |> put_status(404)
    end
  end
end
