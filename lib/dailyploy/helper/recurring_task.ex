defmodule Dailyploy.Helper.RecurringTask do
  alias Dailyploy.Repo
  alias Dailyploy.Model.RecurringTask, as: RTModel
  import DailyployWeb.Helpers

  def create_recurring_task(params) do
    %{
      name: name,
      start_datetime: start_datetime,
      end_datetime: end_datetime,
      comments: comments,
      status: status,
      priority: priority,
      project_ids: project_ids,
      member_ids: member_ids,
      frequency: frequency,
      number: number,
      schedule: schedule,
      week_numbers: week_numbers,
      month_numbers: month_numbers,
      project_members_combination: project_members_combination,
      workspace_id: workspace_id,
      category_id: category_id
    } = params

    verify_create(
      RTModel.create(%{
        name: name,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        comments: comments,
        status: status,
        priority: priority,
        project_ids: project_ids,
        member_ids: member_ids,
        frequency: frequency,
        number: number,
        schedule: schedule,
        week_numbers: week_numbers,
        month_numbers: month_numbers,
        project_members_combination: project_members_combination,
        workspace_id: workspace_id,
        category_id: category_id
      })
    )
  end

  defp verify_create({:ok, recurring_task}) do
    recurring_task =
      recurring_task
      |> Dailyploy.Repo.preload([:category, :workspace])

    {:ok,
     %{
       id: recurring_task.id,
       name: recurring_task.name,
       start_datetime: recurring_task.start_datetime,
       end_datetime: recurring_task.end_datetime,
       comments: recurring_task.comments,
       status: recurring_task.status,
       priority: recurring_task.priority,
       project_ids: recurring_task.project_ids,
       member_ids: recurring_task.member_ids,
       frequency: recurring_task.frequency,
       number: recurring_task.number,
       schedule: recurring_task.schedule,
       week_numbers: recurring_task.week_numbers,
       month_numbers: recurring_task.month_numbers,
       project_members_combination: recurring_task.project_members_combination,
       workspace_id: recurring_task.workspace_id,
       category_id: recurring_task.category_id,
       category: recurring_task.category,
       workspace: recurring_task.workspace
       #  time_tracks: recurring_task.recurring_task.time_tracks,
       #  task_comments: recurring_task.recurring_task.task_comments
     }}
  end

  defp verify_create({:error, recurring_task}) do
    {:error, extract_changeset_error(recurring_task)}
  end
end
