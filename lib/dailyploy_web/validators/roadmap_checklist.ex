defmodule DailyployWeb.Validators.RoadmapChecklist do
  use Params

  defparams(
    verify_checklist(%{
      name!: :string,
      task_lists_id!: :integer,
      is_completed!: [field: :boolean, default: false]
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      task_lists_id!: :integer
    })
  )
end
