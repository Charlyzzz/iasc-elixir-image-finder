defmodule ImageFinder.WorkerSupervisor do
  use Supervisor

  alias ImageFinder.{Worker, WorkerSupervisor, TaskSupervisor}

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_all)
  end

  def append_new_worker(supervisor) do
    task_supervisor_spec = supervisor(TaskSupervisor, [], child_params())
    {:ok, supervisor_pid} = Supervisor.start_child(supervisor, task_supervisor_spec)

    worker_spec = worker(Worker, [supervisor_pid], child_params())
    Supervisor.start_child(supervisor, worker_spec)
  end

  defp child_params, do: [id: make_ref(), restart: :transient]
end
