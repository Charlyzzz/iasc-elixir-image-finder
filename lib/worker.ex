defmodule ImageFinder.Worker do
  use GenServer

  alias ImageFinder.TaskSupervisor

  def start_link(supervisor) do
    GenServer.start_link(__MODULE__, {:ok, supervisor})
  end

  def init({:ok, supervisor}) do
    {:ok, {0, supervisor}}
  end

  def handle_cast({:fetch, source_file, target_directory}, state) do
    {_, task_supervisor} = state
    links_count = source_file
      |> links
      |> start_tasks(target_directory, task_supervisor)
      |> Enum.count

    {:noreply, {links_count, task_supervisor}}
  end

  defp start_tasks(links, target_directory, task_supervisor) do
    Enum.map(links, fn link ->
      TaskSupervisor.append_new_task(link, target_directory, task_supervisor, self())
    end)
  end

  defp links(source_file) do
    content = File.read! source_file
    regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
    Regex.scan(regexp, content)
      |> Enum.map(&List.first/1)
  end
end
