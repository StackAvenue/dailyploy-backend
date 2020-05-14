defmodule Dailyploy.Schema.ReportConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.ReportConfiguration
  alias Dailyploy.Schema.User

  schema "report_configuration" do
    field :is_active, :boolean, default: true
    field :to_mails, {:array, :string}
    field :cc_mails, {:array, :string}
    field :bcc_mails, {:array, :string}
    field :email_text, :string
    belongs_to :workspace, Workspace, on_replace: :delete
    belongs_to :admin, User, on_replace: :delete
    field :user_ids, {:array, :integer}
    field :project_ids, {:array, :integer}
    field :frequency, :string, default: "weekly"

    timestamps()
  end

  def changeset(report_configuration = %ReportConfiguration{}, attrs) do
    report_configuration
    |> cast(attrs, [
      :is_active,
      :to_mails,
      :cc_mails,
      :bcc_mails,
      :email_text,
      :workspace_id,
      :admin_id,
      :user_ids,
      :project_ids,
      :frequency
    ])
    |> validate_required([
      :is_active,
      :to_mails,
      :workspace_id,
      :admin_id,
      :user_ids
    ])
    |> assoc_constraint(:workspace)
    |> assoc_constraint(:admin)
  end
end
