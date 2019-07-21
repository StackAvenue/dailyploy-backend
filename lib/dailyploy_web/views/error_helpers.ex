defmodule DailyployWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  def changeset_error_to_map(errors) do
    Enum.reduce(errors, %{}, fn {error_key, {error_value, _}}, acc ->
      Map.put(acc, error_key, error_value)
    end)
  end
end
