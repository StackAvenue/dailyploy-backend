defmodule DailyployWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  def changeset_error_to_map(errors) do
    Enum.reduce(errors, %{}, fn {error_key, {error_value, _}}, acc ->
      Map.put(acc, error_key, error_value)
    end)
  end

  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(AcqdatApiWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AcqdatApiWeb.Gettext, "errors", msg, opts)
    end
  end

  def render("200.json", assigns) do
    handle_assign_error("", assigns)
  end

  def render("401.json", assigns) do
    :unauthenticated |> err() |> handle_assign_error(assigns)
  end

  def render("403.json", assigns) do
    :unauthorized |> err() |> handle_assign_error(assigns)
  end

  def render("400.json", assigns) do
    :bad_request |> err() |> handle_assign_error(assigns)
  end

  def render("404.json", assigns) do
    :not_found |> err() |> handle_assign_error(assigns)
  end

  def render("500.json", assigns) do
    err(:server_error) |> handle_assign_error(assigns)
  end

  defp handle_assign_error(default_message, assigns) do
    case has_assign_error_key?(assigns) do
      {:ok, errors} ->
        %{errors: %{message: errors}}

      _ ->
        %{errors: %{message: default_message}}
    end
  end

  defp has_assign_error_key?(assigns) do
    if Map.has_key?(assigns, :errors) do
      {:ok, parse_errors(assigns.errors)}
    else
      nil
    end
  end

  defp parse_errors(args) when is_map(args) do
    if Map.has_key?(args, :__struct__) do
      Map.from_struct(args)
    else
      args
    end
  end

  defp parse_errors(args), do: args

  defp err(message) do
    case message do
      :server_error -> "Server Error"
      :not_found -> "Not Found"
      :unknown_resource_type -> "Unknown resource type"
      :unauthenticated -> "Unauthenticated"
      :unauthorized -> "Unauthorized"
      :unexpected_state -> "unexpected_state"
      :bad_request -> "Bad Request"
    end
  end
end
