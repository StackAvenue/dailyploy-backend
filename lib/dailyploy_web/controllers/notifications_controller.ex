defmodule DailyployWeb.NotificationsController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Notification, as: NotificationModel
  alias Dailyploy.Repo
  import DailyployWeb.Helpers

  plug Auth.Pipeline

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
end
