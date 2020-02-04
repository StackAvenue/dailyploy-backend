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
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("confirmation_with_project.html", invitation_details: invitation_details)
    |> Mail.send()
  end

  def send_confirmation_email_without_project(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Confirmation")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("index_without_project.html", invitation_details: invitation_details)
    |> Mail.send()
  end

  def send_invite_email(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")
    [user, _] = String.split(toEmail, "@")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Invitation")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("index.html", invitation_details: invitation_details, user: user)
    |> Mail.send()
  end

  def send_invite_email_without_project(invitation_details) do
    {:ok, toEmail} = Map.fetch(invitation_details, "email")
    [user, _] = String.split(toEmail, "@")

    Email.build()
    |> Email.add_to(toEmail)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("DailyPloy Invitation")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("invitation_email_without_project.html", invitation_details: invitation_details, user: user)
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
