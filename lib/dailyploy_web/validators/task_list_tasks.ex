defmodule DailyployWeb.Validators.TaskListTasks do
  use Params

  defparams(
    verify_task_list(%{
      name!: :string,
      description: :string,
      estimation!: :integer,
      status: :string,
      priority: :string,
      task_id: :integer,
      owner_id: :integer,
      task_status_id: :integer,
      category_id: :integer,
      task_lists_id: :integer,
      user_stories_id: :integer,
      identifier: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      task_lists_id: :integer,
      user_stories_id: :integer
    })
  )
end
