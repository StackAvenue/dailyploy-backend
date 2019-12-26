defmodule DailyployWeb.Validators.TimeTracking do
  use Params

  defparams(
    verify_running_time_tracking(%{
      task_id!: :integer,
      start_time!: :utc_datetime,
      status!: :string,
      end_time: :utc_datetime,
      duration: :integer
    })
  )

  defparams(
    verify_stop_time_tracking(%{
      task_id!: :integer,
      start_time: :utc_datetime,
      status!: :string,
      end_time!: :utc_datetime,
      duration: :integer
    })
  )
end
