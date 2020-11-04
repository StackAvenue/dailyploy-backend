defmodule Dailyploy.Model.Analysis do
    alias Dailyploy.Repo
    import Ecto.Query
    
    alias Dailyploy.Schema.Task
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.TaskListTasks
    alias Dailyploy.Schema.TaskLists
    alias Dailyploy.Schema.UserProject
    alias Dailyploy.Schema.UserTask
    alias Dailyploy.Model.Task, as: TaskModel
    alias Dailyploy.Model.TaskListTasks, as: TLTModel
    
    def get_all_tasks(project_id, start_date, end_date) do
     
      dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)
      roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date)
  
      total_time_spent =
        Enum.map(dashboard_tasks, fn x -> x.time_tracks end)
        |> Enum.concat()
        |> Enum.reduce(0, fn y, acc -> acc + y.duration end)
      
      total_task_count = Enum.count(dashboard_tasks) + Enum.count(roadmap_tasks, fn task -> task.task_id == nil end)
  
      completed_tasks = Enum.count(dashboard_tasks, fn task -> task.is_complete == true end)

      %{"completed_tasks" => completed_tasks, "total_tasks" => total_task_count, "total_time_spent" => (total_time_spent/3600)}
    end

    def get_all_members(project_id) do
      query =
        from projectuser in UserProject,
        where: projectuser.project_id == ^project_id,
        select: projectuser
      
      Repo.all(query) |> Enum.count()
    end
    
    def get_budget(project_id, start_date, end_date) do 
      project_query =
      from project in Project,
      where: project.id == ^project_id, 
      select: project.monthly_budget
     
      project_budget = Repo.one(project_query)

      task_query =
      from task in Task,
      where: task.project_id == ^project_id and task.updated_at > ^start_date and task.updated_at < ^end_date, 
      select: task

      preloaded_data = Repo.all(task_query) |> Repo.preload([:time_tracks, :project, owner: [:user_workspace_settings]])

      user_tasks = Enum.group_by(preloaded_data, fn x -> x.owner_id end) 

      member_time = 
        Enum.map(user_tasks, fn {x, y} -> {x, y |> Enum.map(fn x -> x.time_tracks end) 
        |> Enum.concat() |> Enum.reduce(0, fn y, acc -> (acc + y.duration) end)} end) |> Enum.map(fn {x, y} -> {x, y/3600} end)
          
      user_details = 
        Enum.map(user_tasks, fn {x, y} ->   {x, y |> Enum.map(fn x -> x.owner end) |> List.first()} end) 
        |> Enum.map(fn {x, y} -> {x, y.user_workspace_settings |> Enum.map(fn x -> x.hourly_expense end) |> List.first()} end)
      
      member_expense_total = 
        Enum.concat(member_time, user_details)  
        |> Enum.group_by(fn {x, y} -> x end)  
        |> Enum.map(fn {key, value} ->  {key, value |> Enum.map(fn {x, y} -> y end)} end)
        |> Enum.map(fn { _ , y} -> y |> Enum.reduce(fn x, acc -> x * acc end)end) 
        |> Enum.sum()
      
      case member_expense_total > project_budget do 
        false -> 
          ((project_budget - member_expense_total)/project_budget) * 100 
        true -> 
          "Budget is less than members expense"
      end   
    end

    def get_top_5_members(project_id, start_date, end_date) do 
      query =
      from task in Task,
      where: task.project_id == ^project_id and task.updated_at > ^start_date and task.updated_at < ^end_date and task.is_complete == true, 
      select: task
      
      dashboard_tasks = Repo.all(query) |> Repo.preload([:time_tracks, owner: [:user_workspace_settings]])
      a = Enum.group_by(dashboard_tasks, fn x -> x.owner_id end) 
      task_count = Enum.map(a, fn {x, y} -> %{:user_id => x, "task_count" => y |> Enum.count()} end)
      member_time = Enum.map(a, fn {x, y} -> %{:user_id => x, "time_tracks" => y |> Enum.map(fn x -> x.time_tracks end) 
          |> Enum.concat() |> Enum.reduce(0, fn y, acc -> acc + y.duration end)} end)
      
      user_details = Enum.map(a, fn {x, y} -> {x, y |> Enum.map(fn x -> x.owner end) |> List.first()} end) 
          |> Enum.map(fn {x, y} -> %{:user_id => x, "name" => y.name, "profile_photo" => y.provider_img,
           "expense" => y.user_workspace_settings |> Enum.map(fn x -> x.hourly_expense end) |> List.first()} end)

      r =  Enum.concat(task_count, member_time) |> Enum.concat(user_details) 
          #  |> Enum.map(fn x -> x |> Map.merge() end) 
          #  |> Enum.group_by(fn x -> x.user_id end)
          #  |> Enum.map(fn {key, value} ->  value  end)
    end

    def get_weekly_data(project_id, start_date, end_date) do
      dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)
      roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date)

      total_task_count = Enum.count(dashboard_tasks) + Enum.count(roadmap_tasks, fn task -> task.task_id == nil end)
      
      query =
        from task in Task,
        where: task.project_id == ^project_id and 
        task.updated_at > ^start_date and 
        task.updated_at < ^end_date and  
        task.is_complete == true,
        group_by: fragment("weekData"),
        select:  [fragment("date_trunc('week',?) as weekData", task.updated_at), fragment("count(?)", task)]
      Repo.all(query)
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

        userstory_ids = Enum.map(task_lists, fn task_list -> task_list.user_stories |> Enum.map(fn item -> item.id end ) end)
        userstories_ids = Enum.concat(userstory_ids)

        preload_query_1 = tlt_query(task_list_ids, start_date, end_date)
        preload_query_2 = userstory_query(userstories_ids, start_date, end_date)
  
        preloaded_tasks = task_lists |> Repo.preload([
            task_list_tasks: preload_query_1,
            user_stories: [ task_lists_tasks: preload_query_2 ]
          ])

        roadmap_tasks = Enum.map(preloaded_tasks, fn task_list -> task_list.task_list_tasks end)  
          |> Enum.concat() 
          |> Enum.filter(fn task -> task.task_id == nil end)

        userstory_tasks = Enum.map(preloaded_tasks, fn task_list -> task_list.user_stories  end)
          |> Enum.concat()
          |> Enum.map(fn user_story -> user_story.task_lists_tasks  end)
          |> Enum.concat()
          |> Enum.filter(fn task -> task.task_id == nil end)

       Enum.concat(roadmap_tasks, userstory_tasks)
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
