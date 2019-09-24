defmodule Dailyploy.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserProject

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    many_to_many :workspaces, Workspace, join_through: UserWorkspace
    many_to_many :projects, Project, join_through: UserProject
    many_to_many :tasks, Task, join_through: "user_tasks"

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
      |> cast_assoc(:workspaces, with: &Workspace.changeset/2)
  end

  def update_changeset(user, attrs) do
    user
      |> cast(attrs, [:name, :email, :password, :password_confirmation])
      |> validate_required([:name, :email, :password, :password_confirmation])
      |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
      |> validate_length(:password, min: 8)
      |> validate_confirmation(:password)
      |> put_password_hash
      |> unique_constraint(:email)
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
