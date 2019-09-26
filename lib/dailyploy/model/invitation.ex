defmodule Dailyploy.Model.Invitation do
    alias Dailyploy.Repo
    alias Dailyploy.Schema.Invitation
    alias Dailyploy.Schema.User
    alias Dailyploy.Schema.UserWorkspace
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.Workspace
    alias Dailyploy.Model.User, as: UserModel
    import Ecto.Query

    def list_invitations() do
      Repo.all(Invitation)
    end

    def already_registered_users_and_workspace(invitee_email, _project_id, workspace_id) do
      case UserModel.get_by_email(invitee_email) do
        {:ok , %User{id: user_id }} ->
          query =
            from user in UserWorkspace,
            where: user.workspace_id == ^workspace_id and user.user_id == ^user_id and user.role_id == 2

          case List.first(Repo.all(query)) do
            nil ->  false
            _ -> true
          end
        {:error , _} ->
          false
      end
    end

    def fetch_token_details(token) do
      query = 
        from invitation in Invitation,
        where: invitation.token == ^token
        %Invitation{workspace_id: workspace_id, project_id: project_id, sender_id: sender_id} = List.first(Repo.all(query))
        token_details =  %{"workspace_id" => workspace_id, "project_id" => project_id}
        token_details
    end

    def pass_user_details(actual_user_id, project_id, workspace_id) do
      query =
        from project in Project,
        where: project.id == ^project_id
      %Project{name: name} = List.first(Repo.all(query))
      invitation_details = %{"project_name" => name}

      query =
        from user in User,
        where: user.id == ^actual_user_id
      %User{name: name} = List.first(Repo.all(query))
      invitation_details = Map.put(invitation_details,"user_name",name)

      query =
        from workspace in Workspace,
        where: workspace.id == ^workspace_id
      %Workspace{name: name} = List.first(Repo.all(query))
      invitation_details = Map.put(invitation_details,"workspace_name",name)

      invitation_details
    end

    def pass_user_details_for_non_existing(project_id, workspace_id) do
      query =
        from project in Project,
        where: project.id == ^project_id
      %Project{name: name} = List.first(Repo.all(query))
      invitation_details = %{"project_name" => name}

      query =
        from workspace in Workspace,
        where: workspace.id == ^workspace_id
      %Workspace{name: name} = List.first(Repo.all(query))
      invitation_details = Map.put(invitation_details,"workspace_name",name)

      invitation_details
    end

    def get_invitation!(id), do: Repo.get!(Invitation, id)

    def get_invitation!(id, preloads), do: Repo.get!(Invitation, id) |> Repo.preload(preloads)

    def create_invitation(attrs \\ %{}) do
      %Invitation{}
      |> Invitation.changeset(attrs)
      |> Repo.insert()
    end

    def update_invitation(%Invitation{} = invitation, attrs) do
      invitation
      |> Invitation.changeset(attrs)
      |> Repo.update()
    end

    def delete_invitation(%Invitation{} = invitation) do
      Repo.delete(invitation)
    end
  end
