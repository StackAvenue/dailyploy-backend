defmodule Dailyploy.Helper.Firebase do
    def insert_operation({:ok, json_data}, prefix) do
        Task.async(fn ->
          insert_into_firebase(json_data, prefix)
        end)
      end
    
      defp insert_into_firebase(json_data, prefix) do
        Tesla.post!("https://dailyploy-test.firebaseio.com/#{prefix}.json", json_data, headers: [{"content-type", "application/json"}])
      end
end