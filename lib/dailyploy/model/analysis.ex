defmodule Dailyploy.Model.Analysis do
    alias Dailyploy.Repo
    import Ecto.Query
    
    alias Dailyploy.Schema.Task
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.TaskListTasks
    alias Dailyploy.Schema.TaskLists
    alias Dailyploy.Schema.UserProject
    alias Dailyploy.Model.Task, as: TaskModel
    alias Dailyploy.Model.TaskListTasks, as: TLTModel
    
    def get_all_tasks(project_id, start_date, end_date) do
     
      tasks = get_dashboard_tasks(project_id, start_date, end_date)
      task_lists = get_roadmap_tasks(project_id, start_date, end_date)
  
      total_time_spent =
        Enum.map(tasks, fn x -> x.time_tracks end)
        |> Enum.concat()
        |> Enum.reduce(0, fn y, acc -> acc + y.duration end)
      
        
      # IO.inspect(task_list) 
      
      # is_complete
      # time_tracks
      
      
      d_tasks = Enum.count(tasks)
      c_tasks = Enum.count(tasks, fn task -> task.is_complete == true end)

      # c_atasks = Enum.reduce(tasks, fn task, acc -> task   end)


      # b = Enum.map(task_lists, fn task_list -> task_list.task_list_tasks |> Enum.map(fn task -> task.id end) end)
      # c = Enum.map(task_lists, fn task_list -> task_list.user_stories
      #     |> Enum.map(fn user_story -> user_story.task_lists_tasks
      #     |> Enum.(fn task -> task end) end) end)

      # IO.inspect() 

      # query1 = 
      #   from task in TaskListTasks,
      #   where: task.task_lists_id in ^task_list_ids and task.updated_at > ^start_date and task.updated_at < ^end_date,  
      #   select: task
      #   # from tlt in TaskListTasks,
        #   join: tlt in TaskListTasks,
        #   on: task.project_id == tlt.project_id,
         
      # Repo.all(query1)
    end

    def get_total_duration(project_id, start_date, end_date) do
      tasks = get_dashboard_tasks(project_id, start_date, end_date)
      
    end
    
    defp get_dashboard_tasks(project_id, start_date, end_date) do 
       query =
        from task in Task,
        where: task.project_id == ^project_id and task.updated_at > ^start_date and task.updated_at < ^end_date, 
        select: task
        
        Repo.all(query) |> Repo.preload(:time_tracks)
    end
    
    defp get_roadmap_tasks(project_id, start_date, end_date) do 
      query =
        from tasklist in TaskLists,
        where: tasklist.project_id == ^project_id, 
        select: tasklist
        
        task_lists = Repo.all(query) |> Repo.preload(:user_stories)

        task_list_ids = Enum.map(task_lists, fn task_list -> task_list.id end)

        ids = Enum.map(task_lists, fn task_list -> task_list.user_stories |> Enum.map(fn item -> item.id end ) end)
        userstories_ids = Enum.concat(ids)

        preload_query_1 = tlt_query(task_list_ids, start_date, end_date)
        preload_query_2 = userstory_query(userstories_ids, start_date, end_date)
  
       task_lists
        |> Repo.preload([
          task_list_tasks: preload_query_1,
          user_stories: [ task_lists_tasks: preload_query_2 ]
        ])
      
    end

    defp tlt_query(task_list_ids, start_date, end_date) do 
      query = 
        from task in TaskListTasks,
        where: task.task_lists_id in ^task_list_ids and task.updated_at > ^start_date and task.updated_at < ^end_date,  
        select: task
    end

    defp userstory_query(userstories_ids, start_date, end_date) do 
      query = 
        from task in TaskListTasks,
        where: task.user_stories_id in ^userstories_ids and task.updated_at > ^start_date and task.updated_at < ^end_date,  
        select: task

    end
    
    

    def get_all_members(project_id) do
        # query =
        # from projectuser in UserProject,
        #   where: projectuser.project_id == ^project_id,
        #   select: projectuser
        
        # query = 
        # List.first(Repo.all(query))
        # Repo.all(query)
      end
end
