defmodule Dailyploy.Helper.ReportConfiguration do
  alias Dailyploy.Repo
  alias Dailyploy.Model.ReportConfiguration, as: RCModel
  import DailyployWeb.Helpers

  def create_report_configuration(params) do
    %{
      is_active: is_active,
      to_mails: to_mails,
      cc_mails: cc_mails,
      bcc_mails: bcc_mails,
      email_text: email_text,
      workspace_id: workspace_id,
      admin_id: admin_id,
      user_ids: user_ids,
      project_ids: project_ids,
      frequency: frequency
    } = params

    verify_create(
      RCModel.create(%{
        is_active: is_active,
        to_mails: to_mails,
        cc_mails: cc_mails,
        bcc_mails: bcc_mails,
        email_text: email_text,
        workspace_id: workspace_id,
        admin_id: admin_id,
        user_ids: user_ids,
        project_ids: project_ids,
        frequency: frequency
      })
    )
  end

  defp verify_create({:ok, report_configuration}) do
    report_configuration =
      report_configuration
      |> Repo.preload([:workspace, :admin])

    {:ok,
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
     }}
  end

  defp verify_create({:error, recurring_task}) do
    {:error, extract_changeset_error(recurring_task)}
  end
end
