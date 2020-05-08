defmodule Dailyploy.Model.Notification do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Notification
  import Ecto.Query

  @doc """
  Fetch a particular Notification
  """
  def get(id) do
    Repo.get(Notification, id)
  end

  @doc """
  Fetch all Notifications
  """
  def get_all() do
    Repo.all(Notification)
  end

  @doc """
  Fetch all unreaded Notifications
  """
  def get_unreads(user_id) do
    Notification
    |> where([notification], notification.read == ^false)
    |> where([notification], notification.receiver_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Creates Notification
  """

  def create(params) do
    changeset = Notification.changeset(%Notification{}, params)
    Repo.insert(changeset)
  end

  @doc """
  Updates Notification
  """
  def update(notification, params) do
    changeset = Notification.changeset(notification, params)
    Repo.update(changeset)
  end
end
