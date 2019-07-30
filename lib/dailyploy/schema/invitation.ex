defmodule Dailyploy.Schema.Invitation do 
    use Ecto.Schema
    import Ecto.Changeset
    alias Dailyploy.Schema.Workspace
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.User

    schema "invitations" do
        field :email, :string
        field :token, :string
        field :type, InviteStatusTypeEnum
        belongs_to :workspace, Workspace
        belongs_to :project, Project        
        belongs_to :assignee, User, foreign_key: :assignee_id
        belongs_to :sender, User, foreign_key: :sender_id
        timestamps()
    end

    def changeset(invitation, attrs) do 
        invitation
        |> cast(attrs, [:email, :type, :workspace_id, :project_id, :user_id, :token])
        |> validate_required([:email, :type, :workspace_id, :project_id, :user_id])
        |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)        
        |> genToken
        |> unique_constraint(:email, :token)
        |> put_assoc()
    end  
    
    def genToken(changeset) do 
        length = 32 
        token =  :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
        changeset = %{changeset | token: token} 
    end   
end   