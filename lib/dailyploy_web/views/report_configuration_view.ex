defmodule DailyployWeb.ReportConfigurationView do
  use DailyployWeb, :view
  # alias DailyployWeb.ReportConfigurationView

  def render("show.json", %{report_configuration: report_configuration}) do
    %{
      id: report_configuration.id,
      is_active: report_configuration.is_active,
      to_mails: report_configuration.to_mails,
      cc_mails: report_configuration.cc_mails,
      bcc_mails: report_configuration.bcc_mails,
      email_text: report_configuration.email_text,
      workspace_id: report_configuration.workspace_id,
      admin_id: report_configuration.admin_id,
      user_ids: report_configuration.user_ids,
      project_ids: report_configuration.project_ids,
      frequency: report_configuration.frequency
    }
  end
end
