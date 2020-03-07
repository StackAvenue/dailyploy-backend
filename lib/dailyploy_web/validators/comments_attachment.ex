defmodule DailyployWeb.Validators.CommentsAttachment do
  use Params

  defparams(
    verify_attachment(%{
      task_comment_id!: :integer,
      image_url!: :string
    })
  )
end
