defmodule Dailyploy.Helper.Firebase do
  @production "https://dailyploy-56283.firebaseio.com"
  @test "https://dailyploy-test.firebaseio.com"
  
  def insert_operation({:ok, json_data}, prefix) do
    Task.async(fn ->
      insert_into_firebase(json_data, prefix)
    end)
  end

  defp insert_into_firebase(json_data, prefix) do
    Tesla.post!(@production <> "/#{prefix}.json", json_data,
      headers: [{"content-type", "application/json"}]
    )
  end
end
