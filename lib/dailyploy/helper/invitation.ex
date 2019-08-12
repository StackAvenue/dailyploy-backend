defmodule Dailyploy.Helper.Invitation do
    alias Dailyploy.Model.Invitation, as: InvitationModel
    alias Ecto.Multi
    alias SendGrid.{Mailer, Email}
    
    def create_invite(invite_attrs)  do 
        invite_attrs
        |>
        InvitationModel.create_invitation
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
  end
  