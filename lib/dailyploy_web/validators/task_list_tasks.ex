defmodule DailyployWeb.Validators.TaskListTasks do
  use Params

  defparams(
    verify_task_list(%{
      name!: :string,
      description: :string,
      estimation!: :integer,
      status: :string,
      priority: :string,
      owner_id!: :integer,
      category_id: :integer,
      task_lists_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
