defmodule DailyployWeb.Validators.CommentsAttachment do
  use Params

  defparams(
    verify_attachment(%{
      comment_id!: :integer,
      image_url!: :string
    })
  )
end
