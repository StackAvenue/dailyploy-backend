defmodule DailyployWeb.Validators.ReportConfiguration do
  use Params

  defparams(
    verify_report_configuration(%{
      is_active!: :boolean,
      to_mails!: {:array, :string},
      cc_mails: {:array, :string},
      bcc_mails: {:array, :string},
      email_text: :string,
      workspace_id!: :integer,
      admin_id!: :integer,
      user_ids!: {:array, :integer},
      project_ids: {:array, :integer},
      frequency: :string
    })
  )
end
