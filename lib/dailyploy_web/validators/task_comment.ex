defmodule DailyployWeb.Validators.TaskComment do
  use Params

  defparams(
    verify_task_comment(%{
      task_id: :integer,
      user_stories_id: :integer,
      user_id!: :integer,
      comments: :string
    })
  )
end
