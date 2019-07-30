defmodule Dailyploy.Model.Invitation do
    alias Dailyploy.Repo
    alias Dailyploy.Schema.Invitation
    import Ecto.Query
  
    def list_invitations() do
      Repo.all(Invitation)
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