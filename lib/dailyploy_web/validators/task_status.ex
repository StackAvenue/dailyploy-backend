defmodule DailyployWeb.Validators.TaskStatus do
  use Params

  defparams(
    verify_task_status(%{
      project_id!: :integer,
      workspace_id!: :integer,
      name!: :string,
      is_default!: [field: :boolean, default: false],
      sequence_no!: [field: :integer, default: 0]
    })
  )

  defparams(
    verify_index_params(%{
      project_id!: :integer,
      workspace_id!: :integer,
      page_size: :integer,
      page_number: :integer
    })
  )
end
