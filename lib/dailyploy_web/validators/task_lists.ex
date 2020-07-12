defmodule DailyployWeb.Validators.TaskLists do
  use Params

  defparams(
    verify_project_task_list(%{
      name!: :string,
      start_date!: :date,
      end_date!: :date,
      description: :string,
      color_code: :string,
      workspace_id!: :integer,
      creator_id!: :integer,
      project_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      project_id!: :integer,
      workspace_id!: :integer
    })
  )
end
