defmodule Dailyploy.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.DailyStatusMailSetting

  alias Bcrypt

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :role, :string, virtual: true
    field :provider, :string
    field :provider_id, :string
    field :provider_img, :string
    # is_invited, :boolean, default: false
    has_many :user_workspace_settings, UserWorkspaceSetting

    has_many :daily_status_mail_settings, DailyStatusMailSetting,
      on_delete: :delete_all,
      on_replace: :delete

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
    |> validate_format(:email, ~r/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,})$/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
    |> unique_constraint(:email)
    |> cast_assoc(:workspaces, with: &Workspace.changeset/2)
  end

  def changeset_google_auth(user, attrs) do
    attrs = gen_random_password(attrs)

    user
    |> cast(attrs, [
      :name,
      :email,
      :provider,
      :provider_id,
      :provider_img,
      :password,
      :password_confirmation
    ])
    |> validate_required([
      :name,
      :email,
      :provider,
      :provider_id,
      :provider_img,
      :password,
      :password_confirmation
    ])
    |> validate_format(:email, ~r/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,})$/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
    |> unique_constraint(:email)
    |> cast_assoc(:workspaces, with: &Workspace.changeset/2)
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,})$/)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
    |> unique_constraint(:email)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  defp gen_random_password(changeset) do
    password = :crypto.strong_rand_bytes(8) |> Base.url_encode64() |> binary_part(0, 8)

    changeset
    |> Map.put_new("password", password)
    |> Map.put_new("password_confirmation", password)
  end
end
