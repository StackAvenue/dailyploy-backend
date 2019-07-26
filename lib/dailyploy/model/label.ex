defmodule Dailyploy.Model.Label do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Label

  def create_label(attrs \\ %{}) do
    %Label{}
    |> Label.changeset(attrs)
    |> Repo.insert()
  end

  def delete_label(%Label{} = label) do
    Repo.delete(label)
  end
end
