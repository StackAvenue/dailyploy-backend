defmodule Dailyploy.Helper.Invitation do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Model.Invitation, as: InvitationModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel

  def create_invite(invite_attrs, invitation_details) do
    invite_attrs
    |> get_dep_params
    |> InvitationModel.create_invitation()
    |> get_created_invite(invitation_details)
    |> send_invite_email
  end

  def create_invite_without_project(invite_attrs, invitation_details) do
    invite_attrs
    |> get_dep_params_without_project
    |> InvitationModel.create_invitation()
    |> get_created_invite(invitation_details)
    |> send_invite_email_without_project
  end

  def create_confirmation(invite_attrs, invitation_details) do
    invite_attrs
    |> get_dep_params_for_already_registered
    |> InvitationModel.create_invitation()
    |> get_created_invite(invitation_details)
    |> send_confirmation_email
  end

  def create_confirmation_without_project(invite_attrs, invitation_details) do
    invite_attrs
    |> get_dep_params_for_already_registered_without_project
    |> InvitationModel.create_invitation()
    |> get_created_invite(invitation_details)
    |> send_confirmation_email_without_project
  end

  def send_confirmation_email(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Confirmation")
    |> Email.put_text(
      "Hi #{invitation_details["user_name"]},you have been invited by #{
        invitation_details["sender_name"]
      } and been successfully added to a #{invitation_details["workspace_name"]}'s workspace inside #{
        invitation_details["project_name"]
      } project.Kindly proceed to login to proceed http://dailyploy.com/login/#{
        invitation_details["token_id"]
      }/"
    )
    |> Mail.send()
  end

  def send_confirmation_email_without_project(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Confirmation")
    |> Email.put_text(
      "Hi #{invitation_details["user_name"]},you have been invited by #{
        invitation_details["sender_name"]
      } and been successfully added to a #{invitation_details["workspace_name"]}'s workspace.Kindly proceed to login to proceed http://dailyploy.com/login/#{
        invitation_details["token_id"]
      }/"
    )
    |> Mail.send()
  end

  def send_invite_email(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")
    [user, _] = String.split(toEmail, "@")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Invitation")
    |> Email.put_text(
      "Hi #{user}, DailyPloy is the world's fastest growing Planning Platform and #{
        invitation_details["sender_name"]
      } would like you to also join the DailyPloy's StackAvenue #{
        invitation_details["workspace_name"]
      }'s workspace and invited you to contribute to #{invitation_details["project_name"]} project.
                           So #{user}, whether you are trying to manage your tasks or you want to have a clear visibility of your team's task, check us out and experience the revolution.
                           Click on the following link to proceed http://dailyploy.com/signup/#{
        invitation_details["token_id"]
      }/"
    )
    |> Mail.send()
  end

  def send_invite_email_without_project(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")
    [user, _] = String.split(toEmail, "@")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Invitation")
    |> Email.put_text(
      "Hi #{user}, DailyPloy is the world's fastest growing Planning Platform and #{
        invitation_details["sender_name"]
      } would like you to oin the DailyPloy's StackAvenue #{invitation_details["workspace_name"]}'s workspace.
                           So #{user}, whether you are trying to manage your tasks or you want to have a clear visibility of your team's task, check us out and experience the revolution.
                           Click on the following link to proceed http://dailyploy.com/signup/#{
        invitation_details["token_id"]
      }/"
    )
    |> Mail.send()
  end

  def get_created_invite(attrs, invitation_details) do
    {:ok, invite} = attrs
    {:ok, email} = Map.fetch(invite, :email)
    {:ok, token} = Map.fetch(invite, :token)

    invitation_details
    |> Map.put_new("token_id", token)
    |> Map.put_new("email", email)
  end

  def get_dep_params(attrs) do
    sender = UserModel.get_user!(Map.get(attrs, "sender_id"))
    project = ProjectModel.get_project!(Map.get(attrs, "project_id"))
    workspace = WorkspaceModel.get_workspace!(Map.get(attrs, "workspace_id"))
    role = RoleModel.get_role!(Map.get(attrs, "role_id"))
    token = Map.get(attrs, "token")

    Map.put(attrs, "sender", sender)
    |> Map.put("sender", sender)
    |> Map.put("project", project)
    |> Map.put("workspace", workspace)
    |> Map.put("token", token)
    |> Map.put("role", role)
  end

  def get_dep_params_without_project(attrs) do
    sender = UserModel.get_user!(Map.get(attrs, "sender_id"))
    workspace = WorkspaceModel.get_workspace!(Map.get(attrs, "workspace_id"))
    role = RoleModel.get_role!(Map.get(attrs, "role_id"))
    token = Map.get(attrs, "token")

    Map.put(attrs, "sender", sender)
    |> Map.put("sender", sender)
    |> Map.put("workspace", workspace)
    |> Map.put("token", token)
    |> Map.put("role", role)
  end

  def get_dep_params_for_already_registered(attrs) do
    sender = UserModel.get_user!(Map.get(attrs, "sender_id"))
    project = ProjectModel.get_project!(Map.get(attrs, "project_id"))
    workspace = WorkspaceModel.get_workspace!(Map.get(attrs, "workspace_id"))
    role = RoleModel.get_role!(Map.get(attrs, "role_id"))

    Map.put(attrs, "sender", sender)
    |> Map.put("sender", sender)
    |> Map.put("project", project)
    |> Map.put("workspace", workspace)
    |> Map.put("role", role)
  end

  def get_dep_params_for_already_registered_without_project(attrs) do
    sender = UserModel.get_user!(Map.get(attrs, "sender_id"))
    workspace = WorkspaceModel.get_workspace!(Map.get(attrs, "workspace_id"))
    role = RoleModel.get_role!(Map.get(attrs, "role_id"))

    Map.put(attrs, "sender", sender)
    |> Map.put("sender", sender)
    |> Map.put("workspace", workspace)
    |> Map.put("role", role)
  end
end
