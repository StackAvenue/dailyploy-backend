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

  def check_invitee_user(email) do
    case UserModel.get_by_email(email) do
      {:ok, user} -> {true, user}
      {:error, error} -> {false, error}
    end
  end

  def check_for_user_current_workspace(current_user, invited_workspace_id) do
    query =
      from user_workspace in UserWorkspace,
        where:
          user_workspace.user_id == ^current_user.id and
            user_workspace.workspace_id == ^invited_workspace_id

    List.first(Repo.all(query))
  end

  # def already_registered_users_and_workspace(invitee_email, workspace_id, role_id) do
  #   case UserModel.get_by_email(invitee_email) do
  #     {:ok, %User{id: user_id}} ->
  #       query =
  #         from user in UserWorkspace,
  #           where:
  #             user.workspace_id == ^workspace_id and user.user_id == ^user_id and
  #               user.role_id == ^role_id

  #       case List.first(Repo.all(query)) do
  #         nil -> false
  #         _ -> true
  #       end

  #     {:error, _} ->
  #       false
  #   end
  # end

  def fetch_token_details(token) do
    query =
      from invitation in Invitation,
        where: invitation.token == ^token

    %Invitation{
      name: name,
      working_hours: working_hours,
      role_id: role_id,
      workspace_id: workspace_id,
      email: email,
      project_id: project_id
    } = List.first(Repo.all(query))

    query =
      from workspace in Workspace,
        where: workspace.id == ^workspace_id

    %Workspace{name: workspace_name} = List.first(Repo.all(query))

    token_details = %{
      "name" => name,
      "email" => email,
      "working_hours" => working_hours,
      "role_id" => role_id,
      "workspace_id" => workspace_id,
      "workspace_name" => workspace_name,
      "project_id" => project_id
    }

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
    invitation_details = Map.put(invitation_details, "user_name", name)

    query =
      from workspace in Workspace,
        where: workspace.id == ^workspace_id

    %Workspace{name: name} = List.first(Repo.all(query))
    invitation_details = Map.put(invitation_details, "workspace_name", name)

    invitation_details
  end

  def pass_user_details(actual_user_id, workspace_id) do
    invitation_details = %{}

    query =
      from user in User,
        where: user.id == ^actual_user_id

    %User{name: name} = List.first(Repo.all(query))
    invitation_details = Map.put(invitation_details, "user_name", name)

    query =
      from workspace in Workspace,
        where: workspace.id == ^workspace_id

    %Workspace{name: name} = List.first(Repo.all(query))
    invitation_details = Map.put(invitation_details, "workspace_name", name)

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
    invitation_details = Map.put(invitation_details, "workspace_name", name)

    invitation_details
  end

  def pass_user_details_for_non_existing(workspace_id) do
    query =
      from workspace in Workspace,
        where: workspace.id == ^workspace_id

    %Workspace{name: name} = List.first(Repo.all(query))
    invitation_details = %{"workspace_name" => name}

    invitation_details
  end

  def list_invited_users(workspace_id, project_id) do
    from(invited_users in Invitation,
      where:
        invited_users.workspace_id == ^workspace_id and invited_users.project_id == ^project_id and
          invited_users.status == ^0
    )
    |> Repo.all()
  end

  def get_invitation_with_token(token_id) do
    query =
      from(invitation in Invitation,
        where: invitation.token == ^token_id,
        select: invitation
      )

    {:ok, List.first(Repo.all(query))}
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
    |> Invitation.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end
end
