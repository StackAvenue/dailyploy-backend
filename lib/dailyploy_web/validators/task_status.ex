defmodule DailyployWeb.Validators.TaskStatus do
  use Params

  defparams(
    verify_task_status(%{
      project_id!: :integer,
      workspace_id!: :integer,
      name!: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
