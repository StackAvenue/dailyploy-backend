defmodule Dailyploy.Schema.Notification do
  @moduledoc """
  Models Notifications in the system.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Notification.Data

  schema "notifications" do
    field(:read, :boolean, default: false)

    # associations
    belongs_to(:receiver, User)
    belongs_to(:creator, User)
    belongs_to(:workspace, Workspace)

    # embedded associations
    embeds_one(:data, Data)

    timestamps()
  end

  @required ~w(receiver_id creator_id workspace_id)a
  @optional ~w(read)a
  @permitted @optional ++ @required

  def changeset(notification, params) do
    notification
    |> cast(params, @permitted)
    |> cast_embed(:data, with: &Data.changeset/2)
    |> validate_required(@required)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:receiver)
    |> assoc_constraint(:workspace)
  end
end

defmodule Dailyploy.Schema.Notification.Data do
  @moduledoc """
  Embed schema for data related to notifications.
  """

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:message, :string)
    field(:source, :string)
  end

  @permitted ~w(message source)a

  def changeset(notification, params) do
    notification
    |> cast(params, @permitted)
  end
end
