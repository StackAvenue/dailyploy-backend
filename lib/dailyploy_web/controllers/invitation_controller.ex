defmodule DailyployWeb.InvitationController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.Invitation
  alias Dailyploy.Schema.User
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Invitation, as: InvitationModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Helper.User, as: UserHelper
  alias Dailyploy.Helper.Invitation, as: InvitationHelper

  action_fallback DailyployWeb.FallbackController
  plug Auth.Pipeline
  plug :get_invitation_by_id when action in [:show, :update, :delete]
  plug :check_for_user_inviting_oneself when action in [:create]

  def index(conn, _params) do
    invitations = InvitationModel.list_invitations()
    render(conn, "index.json", invitations: invitations)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"invitation" => invite_attrs}) do
    case conn.status do
      404 ->
        conn
        |> send_resp(404, "User Inviting Self")

      202 ->
        %{"email" => invitee_email} = invite_attrs

        case check_for_new_or_already_registered_user(invitee_email) do
          {true, invited_user} ->
            check_for_user_workspace(
              conn,
              invited_user,
              invite_attrs["workspace_id"],
              Guardian.Plug.current_resource(conn)
            )

          true ->
            create_invitation_for_new_user(
              conn,
              invite_attrs,
              Guardian.Plug.current_resource(conn)
            )
        end
    end
  end

  defp check_for_user_workspace(conn, invited_user, invited_workspace_id, current_user) do
    case is_nil(
           InvitationModel.check_for_user_current_workspace(invited_user, invited_workspace_id)
         ) do
      false ->
        conn
        |> put_status(402)
        |> json(%{"user_already_exists" => true})

      true ->
        %{params: %{"invitation" => invite_attrs}} = conn
        invite_attrs = Map.put(invite_attrs, "sender_id", current_user.id)

        case is_number(invite_attrs["project_id"]) do
          false ->
            invitation_details =
              InvitationModel.pass_user_details(invited_user.id, invited_workspace_id)

            invitation_details = Map.put(invitation_details, "sender_name", current_user.name)

            UserHelper.add_existing_or_non_existing_user_to_member_for_invite(
              invited_user.id,
              invited_workspace_id,
              invite_attrs["working_hours"],
              invite_attrs["role_id"],
              invite_attrs["hourly_expense"]
            )

            case InvitationHelper.create_confirmation_without_project(
                   invite_attrs,
                   invitation_details
                 ) do
              :ok ->
                conn
                |> put_status(:created)
                |> render("invite.json", %{isCreated: true})

              {:error, invitation} ->
                conn
                |> put_status(422)
                |> render("changeset_error.json", %{invitation: invitation.errors})
            end

          true ->
            invitation_details =
              InvitationModel.pass_user_details(
                invited_user.id,
                invite_attrs["project_id"],
                invited_workspace_id
              )

            invitation_details = Map.put(invitation_details, "sender_name", current_user.name)

            UserHelper.add_existing_or_non_existing_user_to_member(
              invited_user.id,
              invited_workspace_id,
              invite_attrs["project_id"],
              invite_attrs["working_hours"],
              invite_attrs["role_id"],
              invite_attrs["hourly_expense"]
            )

            case InvitationHelper.create_confirmation(invite_attrs, invitation_details) do
              :ok ->
                conn
                |> put_status(:created)
                |> render("invite.json", %{isCreated: true})

              {:error, invitation} ->
                conn
                |> put_status(422)
                |> render("changeset_error.json", %{invitation: invitation.errors})
            end
        end
    end
  end

  defp create_invitation_for_new_user(conn, invite_attrs, current_user) do
    case is_number(invite_attrs["project_id"]) do
      false ->
        invitation_details =
          InvitationModel.pass_user_details_for_non_existing(invite_attrs["workspace_id"])

        invitation_details = Map.put(invitation_details, "sender_name", current_user.name)
        invite_attrs = Map.put(invite_attrs, "sender_id", current_user.id)

        case InvitationHelper.create_invite_without_project(invite_attrs, invitation_details) do
          :ok ->
            conn
            |> put_status(:created)
            |> render("invite.json", %{isCreated: true})

          {:error, invitation} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{invitation: invitation.errors})
        end

      true ->
        invitation_details =
          InvitationModel.pass_user_details_for_non_existing(
            invite_attrs["project_id"],
            invite_attrs["workspace_id"]
          )

        invitation_details = Map.put(invitation_details, "sender_name", current_user.name)
        invite_attrs = Map.put(invite_attrs, "sender_id", current_user.id)

        case InvitationHelper.create_invite(invite_attrs, invitation_details) do
          :ok ->
            conn
            |> put_status(:created)
            |> render("invite.json", %{isCreated: true})

          {:error, invitation} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{invitation: invitation.errors})
        end
    end
  end

  defp check_for_new_or_already_registered_user(email) do
    with {true, user} <- InvitationModel.check_invitee_user(email) do
      {true, user}
    else
      {false, error} -> true
    end
  end

  def show(conn, _) do
    invitation = conn.assigns.invitation
    render(conn, "show.json", invitation: invitation)
  end

  def update(conn, %{"invitation" => invite_attrs}) do
    invitation = conn.assigns.invitation

    case InvitationModel.update_invitation(invitation, invite_attrs) do
      {:ok, %Invitation{} = invitation} ->
        conn
        |> put_status(:created)
        |> render(conn, "show.json", invitation: invitation)

      {:error, _} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{invitation: invitation.errors})
    end
  end

  def delete(conn, _) do
    invitation = conn.assigns.invitation

    with {:ok, %Invitation{}} <- InvitationModel.delete_invitation(invitation) do
      send_resp(conn, :no_content, "Invitation Deleted Successfully")
    end
  end

  defp get_invitation_by_id(%{params: %{"id" => id}} = conn, _) do
    case InvitationModel.get_invitation!(id) do
      %Invitation{} = invitation ->
        assign(conn, :invitation, invitation)

      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  defp check_for_user_inviting_oneself(
         %{params: %{"invitation" => %{"email" => invitee_email}}} = conn,
         _params
       ) do
    %{email: current_user_email} = Guardian.Plug.current_resource(conn)

    case invitee_email == current_user_email do
      true ->
        conn
        |> put_status(404)

      false ->
        conn
        |> put_status(202)
    end
  end
end
