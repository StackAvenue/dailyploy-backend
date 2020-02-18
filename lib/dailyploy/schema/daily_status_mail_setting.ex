defmodule Dailyploy.Schema.DailyStatusMailSetting do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.User

  schema "daily_status_mail_settings" do
    field :is_active, :boolean, default: true
    field :to_mails, {:array, :string}
    field :cc_mails, {:array, :string}
    field :bcc_mails, {:array, :string}
    field :email_text, :string
    belongs_to :workspace, Workspace, on_replace: :delete
    belongs_to :user, User, on_replace: :delete
    timestamps()
  end

  def changeset(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
    |> cast(attrs, [
      :is_active,
      :to_mails,
      :cc_mails,
      :bcc_mails,
      :email_text,
      :workspace_id,
      :user_id
    ])
    |> validate_required([
      :is_active,
      :to_mails,
      :email_text,
      :workspace_id,
      :user_id
    ])
    |> assoc_constraint(:workspace)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_workspace_status_uniqueness, name: :user_workspace_unique_status)
  end

  def update_changeset(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
    |> cast(attrs, [:is_active, :to_mails, :cc_mails, :bcc_mails, :email_text])
  end
end
