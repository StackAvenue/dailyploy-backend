defmodule Dailyploy.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Member
  alias Dailyploy.Schema.Invitation  

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    
    has_many :invitation_to, Invitation
    has_many :invitation_from, Invitation
    many_to_many :workspaces, Workspace, join_through: Member

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
    |> unique_constraint(:email)
    |> cast_assoc(:workspaces, required: true, with: &Workspace.changeset/2)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
