defmodule Blitzy.Supervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok)
  end
  
  def init(:ok) do
    IO.puts "starting Blitzy.TasksSupervisor"
    children = [
      supervisor(Task.Supervisor, [[name: Blitzy.TasksSupervisor]])
    ]
    supervise(children, [strategy: :one_for_one])
  end
end