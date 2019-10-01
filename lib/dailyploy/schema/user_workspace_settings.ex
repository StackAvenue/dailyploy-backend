defmodule Dailyploy.Schema.UserWorkspaceSettings do
    use Ecto.Schema
    import Ecto.Changeset

    alias Dailyploy.Schema.User
    alias Dailyploy.Schema.Workspace

    schema "user_workspace_settings" do
        belongs_to :user, User
        belongs_to :workspace, Workspace

        timestamps()
    end

    def changeset(user_workspace_settings, attrs) do
        user_workspace_settings
          |> cast(attrs , [:user_id, :workspace_id])
          |> validate_required([:user_id, :workspace_id])
          |> put_assoc(:user, attrs["user"])
          |> put_assoc(:workspace, attrs["workspace"])
          |> validate_required([:user, :workspace])
    end
end