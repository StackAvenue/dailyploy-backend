defmodule DailyployWeb.Validators.UserStories do
  use Params

  defparams(
    verify_user_stories(%{
      name!: :string,
      description: :string,
      task_status_id!: :integer,
      is_completed!: [field: :string, default: false],
      owner_id: :integer,
      task_lists_id!: :integer,
      priority: :string,
      due_date: :utc_datetime
    })
  )

  defparams(
    verify_attachments(%{
      user_stories_id!: :integer,
      image_url!: :string
    })
  )
end
