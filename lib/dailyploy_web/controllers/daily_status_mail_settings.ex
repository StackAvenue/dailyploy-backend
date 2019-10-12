defmodule DailyployWeb.DailyStatusMailSettings do
    use DailyployWeb, :controller
    import Plug.Conn
    alias Dailyploy.Schema.DailyStatusMailSettings
    alias Dailyploy.Model.DailyStatusMailSettings, as: DailyStatusMailSettingsModel

    action_fallback DailyployWeb.FallbackController
    plug Auth.Pipeline

    def update(conn, user_params) do
        DailyStatusMailSettingsModel.create(user_params)
         #DailyStatusMailSettingsModel.stop_and_resume(user_params)   
    end
    
   
end