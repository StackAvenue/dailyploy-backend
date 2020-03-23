defmodule Dailyploy.Helper.SendText do
  @link "https://api.textlocal.in/send/?"
  apikey = System.get_env("text_locat_apikey")

  def text_operation(message, phone_number) do
    Task.async(fn ->
      send_text(message, phone_number)
    end)
  end

  defp send_text(message, phone_number) do
    phone_number =
      case String.length(phone_number) do
        10 -> "91" <> phone_number
        12 -> phone_number
      end

    message = URI.encode(message)
    apikey = System.get_env("text_locat_apikey")
    link = @link <> "message=#{message}&numbers=#{phone_number}&apikey=#{apikey}"
    HTTPotion.post!(link)
  end
end
