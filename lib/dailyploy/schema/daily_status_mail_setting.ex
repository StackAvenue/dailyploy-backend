defmodule Dailyploy.Schema.DailyStatusMailSetting do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias Dailyploy.Schema.Workspace 

  schema "daily_status_mail_settings" do
    field :is_active, :boolean, default: true
    field :to_mails, {:array, :string}
    field :cc_mails, {:array, :string}
    field :bcc_mails, {:array, :string}
    field :email_text, :string
    belongs_to :workspace, Workspace

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
      :workspace_id
    ])
    |> validate_required([
      :is_active,
      :to_mails,
      :email_text,
      :workspace_id
    ])
    |> assoc_constraint(:workspace)
    |> unique_constraint(:workspace_id)
  end

  def update_changeset(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
    |> cast(attrs, [:is_active, :to_mails, :cc_mails, :bcc_mails, :email_text])
  end
end
