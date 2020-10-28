defmodule Dailyploy.Model.Analysis do
    alias Dailyploy.Repo
    import Ecto.Query
    
    alias Dailyploy.Schema.Task
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.TaskListTasks
    alias Dailyploy.Schema.UserProject
    alias Dailyploy.Model.Task, as: TaskModel
    alias Dailyploy.Model.TaskListTasks, as: TLTModel
    
    def get_all_tasks(project_id) do
      query =
        # from task in Task,
        from tlt in TaskListTasks,
        #   join: tlt in TaskListTasks,
        #   on: task.project_id == tlt.project_id,
        where: tlt.project_id ==  ^project_id, 
        select: count(tlt)

      List.first(Repo.all(query))
    end

    def get_all_members(project_id) do
        # query =
        # from projectuser in UserProject,
        #   where: projectuser.project_id == ^project_id,
        #   select: projectuser
        
        query = 
        # List.first(Repo.all(query))
        Repo.all(query)
      end
end
