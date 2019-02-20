defmodule Blitzy do
  use Application

  def start(_type, _args) do
    IO.puts "Starting top level supervisor..."
    Blitzy.Supervisor.start_link(:ok)
  end

end
