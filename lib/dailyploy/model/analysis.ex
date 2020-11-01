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
      
        
      #totdal dashboard task  
      dashboard_tasks = Enum.count(tasks)
      
      completed_tasks = Enum.count(tasks, fn task -> task.is_complete == true end)

    
       #roadmap task
        roadmap_tasks = Enum.map(task_lists, fn task_list -> task_list.task_list_tasks end)  
          |> Enum.concat() 
          |> Enum.filter(fn task -> task.task_id == nil end)
          |> Enum.count()

        #userstory task
       userstory_tasks = Enum.map(task_lists, fn task_list -> task_list.user_stories  end)
          |> Enum.concat()
          |> Enum.map(fn user_story -> user_story.task_lists_tasks  end)
          |> Enum.concat()
          |> Enum.filter(fn task -> task.task_id == nil end)
          |> Enum.count()

      total_task_count = dashboard_tasks + roadmap_tasks + userstory_tasks

      %{"completed_tasks" => completed_tasks, "total_tasks" => total_task_count, "total_time_spent" => total_time_spent}
    end

    def get_all_members(project_id) do
      query =
        from projectuser in UserProject,
        where: projectuser.project_id == ^project_id,
        select: projectuser
      
      Repo.all(query) |> Enum.count()
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

end
