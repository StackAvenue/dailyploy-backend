defmodule Dailyploy.Schema.Invitation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Role

  schema "invitations" do
    field :email, :string
    field :token, :string
    field :name, :string
    field :working_hours, :integer
    field :status, InviteStatusTypeEnum
    belongs_to :role, Role
    belongs_to :workspace, Workspace
    belongs_to :project, Project
    belongs_to :sender, User

    timestamps()
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :status, :token, :name, :working_hours])
    |> validate_required([:email, :status])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> genToken(attrs)
    |> unique_constraint(:email)
    |> put_assoc(:workspace, attrs["workspace"])
    |> put_assoc(:project, attrs["project"])
    |> put_assoc(:sender, attrs["sender"])
    |> put_assoc(:role, attrs["role"])
    |> validate_required([:workspace, :sender, :role])
  end

  def update_changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  defp genToken(changeset, attrs) do
    %{
      "email" => email,
      "workspace" => %Workspace{name: workspace_name}
    } = attrs

    str = "#{email}#{workspace_name}"
    # workspace id project_id email _id unique id
    token =
      String.length(str)
      |> :crypto.strong_rand_bytes()
      |> Base.encode32()
      |> binary_part(0, String.length(str))

    put_change(changeset, :token, token)
  end
end
