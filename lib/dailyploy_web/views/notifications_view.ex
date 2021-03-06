defmodule DailyployWeb.NotificationsView do
  use DailyployWeb, :view
  alias DailyployWeb.NotificationsView

  def render("index.json", %{notifications: notifications}) do
    %{notifications: render_many(notifications, NotificationsView, "notification_details.json")}
  end

  def render("notification_details.json", %{notifications: notification}) do
    %{
      id: notification.id,
      read: notification.read,
      data: Map.from_struct(notification.data),
      inserted_at: notification.inserted_at
    }
  end

  def render("notification_mark_as_read_success.json", %{message: message}) do
    %{
      status: message
    }
  end
end
