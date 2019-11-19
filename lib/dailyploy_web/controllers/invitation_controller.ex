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

    def index(conn, _params) do
      invitations = InvitationModel.list_invitations()
      render(conn, "index.json", invitations: invitations)
    end

    @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
    def create(conn, %{"invitation" => invite_attrs}) do
      %{"email" => invitee_email, "project_id" => project_id, "workspace_id" => workspace_id} = invite_attrs
      %User{id: sender_id, email: user_email, name: sender_name} = Guardian.Plug.current_resource(conn)
      invite_attrs = Map.put(invite_attrs,"sender_id",sender_id)
      %{role_id: role_id} = UserWorkspaceModel.get_member_role(workspace_id)
      case (user_email == invitee_email || InvitationModel.already_registered_users_and_workspace(invitee_email, project_id, workspace_id)) do
        true -> send_resp(conn, 401, "UNAUTHORIZED")
        false ->
          case role_id do
          2 -> send_resp(conn, 401, "UNAUTHORIZED")
          1 ->
            case UserModel.get_by_email(invitee_email) do
              {:ok , %User{id: actual_user_id }} ->
                invitation_details = InvitationModel.pass_user_details(actual_user_id, project_id, workspace_id)
                invitation_details = Map.put(invitation_details,"sender_name",sender_name)
                UserHelper.add_existing_or_non_existing_user_to_member(actual_user_id,workspace_id,project_id,8)
                case InvitationHelper.create_confirmation(invite_attrs,invitation_details) do
                  :ok ->
                    conn
                      |> put_status(:created)
                      |> render("invite.json", %{isCreated: true})

                 {:error, invitation} ->
                     conn
                      |> put_status(422)
                      |> render("changeset_error.json", %{invitation: invitation.errors})
                end
              {:error , _} ->
                invitation_details = InvitationModel.pass_user_details_for_non_existing(project_id, workspace_id)
                invitation_details = Map.put(invitation_details,"sender_name",sender_name)
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
        _ -> send_resp(conn, 404, "Not Found")
      end
    end
  end
