defmodule DailyployWeb.InvitationView do
    use DailyployWeb, :view
    alias DailyployWeb.InvitationView
    alias DailyployWeb.ErrorHelpers
  
    def render("index.json", %{invitations: invitations}) do
      %{invitation: render_many(invitations, InvitationView, "invitation.json")}
    end
  
    def render("show.json", %{invitation: invitation}) do
      %{invitation: render_one(invitation, InvitationView, "invitation.json")}
    end
  
    def render("Testinvitation.json", %{invitation: invitation}) do
      %{id: invitation.id, status: invitation.status, token: invitation.token}
    end
      
    def render("invitation.json", true) do
      %{status: true}
    end

    def render("changeset_error.json", %{errors: errors}) do
      %{errors: ErrorHelpers.changeset_error_to_map(errors)}
    end
  end
  