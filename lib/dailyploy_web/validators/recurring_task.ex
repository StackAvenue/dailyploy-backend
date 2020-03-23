defmodule DailyployWeb.Validators.RecurringTask do
  use Params

  defparams(
    verify_recurring_task(%{
      name!: :string,
      start_datetime!: :utc_datetime,
      end_datetime: :utc_datetime,
      comments: :string,
      project_ids!: {:array, :integer},
      member_ids!: {:array, :integer},
      category_id!: :integer,
      status!: :string,
      priority!: :string,
      frequency!: :string,
      number: :integer,
      schedule: :boolean,
      week_numbers: {:array, :integer},
      month_numbers: {:array, :integer},
      workspace_id!: :integer,
      project_members_combination!: :map
    })
  )
end
