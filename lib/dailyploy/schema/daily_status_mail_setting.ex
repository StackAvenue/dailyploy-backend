defmodule Dailyploy.Schema.DailyStatusMailSetting do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.UserWorkspaceSetting

  schema "daily_status_mail_settings" do
    field :is_active, :boolean, default: true
    field :to_mails, {:array, :string}
    field :cc_mails, {:array, :string}
    field :bcc_mails, {:array, :string}
    field :email_text, :string
    belongs_to :user_workspace_setting, UserWorkspaceSetting

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
      :user_workspace_setting_id
    ])
    |> validate_required([
      :is_active,
      :to_mails,
      :cc_mails,
      :bcc_mails,
      :email_text,
      :user_workspace_setting_id
    ])
    |> assoc_constraint(:user_workspace_setting)
    |> unique_constraint(:daily_status_mail_settings_uniqeness,
      name: :daily_status_mail_settings_user_workspace_setting_id_index
    )

    # |> put_assoc(:user_workspace_setting_id, with: &UserWorkspaceSetting.changeset/2 )
  end

  def update_changeset(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
    |> cast(attrs, [:is_active, :to_mails, :cc_mails, :bcc_mails, :email_text])
  end
end
