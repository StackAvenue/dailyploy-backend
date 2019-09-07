defmodule Dailyploy.Helper.Invitation do
    alias Dailyploy.Model.Invitation, as: InvitationModel
    alias Dailyploy.Model.User, as: UserModel
    alias Dailyploy.Model.Project, as: ProjectModel
    alias Dailyploy.Model.Workspace, as: WorkspaceModel
    alias Ecto.Multi
    alias Dailyploy.Repo
    alias Dailyploy.Schema.User
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.Workspace
    alias Dailyploy.Schema.Invitation
    alias SendGrid.{Mailer, Email}
    
    def create_invite(invite_attrs)  do
        invite_attrs
        |>get_dep_params
        |>InvitationModel.create_invitation
        |>get_created_invite
        |>send_invite_email
    end

    def send_invite_email(toEmail) do
        Email.build()
        |> Email.add_to(toEmail)
        |> Email.put_from("contact@stack-avenue.com")
        |> Email.put_subject("DailyPloy Invitation")
        |> Email.put_text("Hi Aishwarya,
        DailyPloy is the world's fastest growing Planning Platform and Alam would like you to also join the DailyPloy's StackAvenue workspace.
        So Aishwarya, whether you are trying to manage your tasks or you want to have a clear visibility of your team's task, check us out and experience the revolution.")
        |> Mailer.send()        
    end

    def get_created_invite(attrs) do 
        {:ok, invite} = attrs
        {:ok, email} = Map.fetch(invite, :email)
        email
    end

    def get_dep_params(attrs) do 
        sender = UserModel.get_user!(Map.get(attrs, "sender_id"))
        assignee = UserModel.get_user!(Map.get(attrs, "assignee_id"))
        project = ProjectModel.get_project!(Map.get(attrs, "project_id"))
        workspace = WorkspaceModel.get_workspace!(Map.get(attrs, "workspace_id"))
        Map.put(attrs, "sender", sender)
        |>Map.put("sender", sender)
        |>Map.put("assignee", assignee)
        |>Map.put("project", project)
        |>Map.put("workspace", workspace)
    end
  end
  