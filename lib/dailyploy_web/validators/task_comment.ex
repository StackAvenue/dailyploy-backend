defmodule DailyployWeb.Validators.TaskComment do
  use Params

  defparams(
    verify_task_comment(%{
      task_id: :integer,
      user_stories_id: :integer,
      user_id!: :integer,
      task_list_tasks_id: :integer,
      comments: :string
    })
  )
end
