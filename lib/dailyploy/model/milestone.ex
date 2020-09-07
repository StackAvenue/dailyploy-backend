defmodule Dailyploy.Model.Milestone do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Milestone

  import Ecto.Query

  def create_milestone(attrs \\ %{}) do
    %Milestone{}
    |> Milestone.changeset(attrs)
    |> Repo.insert()
  end

  def get_milestones(project_id, start_date, end_date) do
    query =
      from milestone in Milestone,
        where:
          milestone.project_id == ^project_id and
            milestone.due_date >= ^start_date and
            milestone.due_date <= ^end_date,
        order_by: [desc: milestone.due_date]

    Repo.all(query)
  end

  def get_milestone!(id), do: Repo.get(Milestone, id)

  def update_milestone(milestone, attrs) do
    milestone
    |> Milestone.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_milestone(%Milestone{} = milestone) do
    Repo.delete(milestone)
  end
end
