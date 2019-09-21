defmodule DailyployWeb.InvitationController do
    use DailyployWeb, :controller
    import Plug.Conn
    
    alias Dailyploy.Model.User, as: UserModel
    alias Dailyploy.Schema.User
    alias Dailyploy.Model.Invitation, as: InvitationModel
    alias Dailyploy.Helper.Invitation, as: InvitationHelper
    alias Dailyploy.Schema.Invitation
    alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
    alias Dailyploy.Schema.UserWorkspace
    alias Dailyploy.Helper.User, as: UserHelper
  
    action_fallback DailyployWeb.FallbackController
    plug :get_invitation_by_id when action in [:show, :update, :delete]


    def index(conn, _params) do
      invitations = InvitationModel.list_invitations()                        
      render(conn, "index.json", invitations: invitations)
    end
  
    @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
    def create(conn, %{"invitation" => invite_attrs}) do
      %{"email" => invitee_email, "project_id" => project_id, "workspace_id"=> workspace_id} = invite_attrs
      %{role_id: role_id} = UserWorkspaceModel.get_member_role(workspace_id)
      case role_id do
        2 -> send_resp(conn, 401, "UNAUTHORIZED")
        1 -> 
          case UserModel.get_by_email(invitee_email) do
            {:ok , %User{id: actual_user_id }} -> 
              UserHelper.add_existing_or_non_existing_user_to_member(actual_user_id,workspace_id,project_id)
              case InvitationHelper.create_confirmation(invite_attrs) do
                :ok ->
                  conn
                  |> put_status(:created)
                  |> render("invite.json", %{isCreated: true})
      
                {:error, invitation} ->
                  conn
                  |> put_status(422)
                  |> render("changeset_error.json", %{invitation: invitation.errors})
                  
              end
              {:error , str } -> 
 #             %{assigns: %{ invitation: %Invitation{token: token_id}}} = conn
 #             invite_attrs = Map.put(invite_attrs,"token",token_id)
              case InvitationHelper.create_invite(invite_attrs) do
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

        {:error, user} ->
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
  