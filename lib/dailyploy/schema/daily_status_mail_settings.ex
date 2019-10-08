defmodule Dailyploy.Schema.DailyStatusMailSettings do 
    use Ecto.Schema
    import Ecto.Changeset
    alias Dailyploy.Schema.UserWorkspaceSettings

    schema "daily_status_mail_settings" do
        field :is_active, :boolean , default: true
        field :to_mails, {:array, :string}
        field :cc_mails, {:array, :string}
        field :bcc_mails, {:array, :string}
        field :email_text, :string
        belongs_to :user_workspace_settings, UserWorkspaceSettings
        
        timestamps()
    end

    def changeset(daily_status_mail_settings, attrs) do 
        daily_status_mail_settings
        |> cast(attrs, [:is_active, :to_mails, :cc_mails, :bcc_mails, :email_text])
        |> cast_assoc(:user_workspace_setting_id)
        |> validate_required([:is_active, :to_mails, :cc_mails, :bcc_mails, :email_text, :user_workspace_setting_id])    
        #|> put_assoc(:user_workspace_setting_id, with: &UserWorkspaceSettings.changeset/2 )
    end   
end   