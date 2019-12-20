defmodule DailyployWeb.UserWorkspaceSettingsView do
  use DailyployWeb, :view
  alias DailyployWeb.UserWorkspaceSettingsView
  alias DailyployWeb.ErrorHelpers

  def render("show.json", %{workspace: workspace}) do
    %{workspace_id: workspace.id, workspace_role: workspace.name}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("index.json", %{daily_status: daily_status}) do
    bcc_mails = %{}
    cc_mails = %{}

    {:ok, %{bcc_mails: bcc_mails}} =
      with false <- is_nil(daily_status.bcc_mails) do
        {:ok, Map.put(bcc_mails, :bcc_mails, daily_status.bcc_mails)}
      else
        true ->
          {:ok, %{bcc_mails: []}}
      end

    {:ok, %{cc_mails: cc_mails}} =
      with false <- is_nil(daily_status.cc_mails) do
        {:ok, Map.put(cc_mails, :cc_mails, daily_status.cc_mails)}
      else
        true ->
          {:ok, %{cc_mails: []}}
      end

    %{
      to_mails: daily_status.to_mails,
      id: daily_status.id,
      workspace_id: daily_status.workspace_id,
      is_active: daily_status.is_active,
      bcc_mails: bcc_mails,
      cc_mails: cc_mails
    }
  end

  def render("index_for_show.json", %{daily_status_mail: daily_status_mail}) do
    bcc_mails = %{}
    cc_mails = %{}

    {:ok, %{bcc_mails: bcc_mails}} =
      with false <- is_nil(daily_status_mail.bcc_mails) do
        {:ok, Map.put(bcc_mails, :bcc_mails, daily_status_mail.bcc_mails)}
      else
        true ->
          {:ok, %{bcc_mails: []}}
      end

      {:ok, %{cc_mails: cc_mails}} =
      with false <- is_nil(daily_status_mail.cc_mails) do
        {:ok, Map.put(cc_mails, :cc_mails, daily_status_mail.cc_mails)}
      else
        true ->
          {:ok, %{cc_mails: []}}
      end

    %{
      to_mails: daily_status_mail.to_mails,
      id: daily_status_mail.id,
      workspace_id: daily_status_mail.workspace_id,
      is_active: daily_status_mail.is_active,
      bcc_mails: bcc_mails,
      cc_mails: cc_mails,
      email_text: daily_status_mail.email_text
    }
  end

  def render("daily_status_mail.json", %{daily_status_mail: daily_status_mail}) do
    %{
      email_text: daily_status_mail.email_text,
      to_mails: daily_status_mail.to_mails,
      daily_status_mail_id: daily_status_mail.id,
      is_active: daily_status_mail.is_active
    }
  end
end
