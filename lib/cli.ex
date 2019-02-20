use Mix.Config
defmodule Blitzy.CLI do
  require Logger

  def main(args) do
    Logger.info "Starting master_node"
    Application.get_env(:blitzy, :master_node)
      |> Node.start

    Application.get_env(:blitzy, :slave_nodes)
      |> Enum.each(&Node.connect(&1))

    args
      |> parse_args
      |> process_options([node|Node.list])
  end

  defp parse_args(args) do
    OptionParser.parse(
      args, 
      aliases: [n: :requests],
      strict: [requests: :integer]
    )
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(n, url, nodes)
      _ -> do_help
    end
  end

  defp do_requests(n, url, nodes) do
    Logger.info "Blasting #{url} with #{n} requests..."
    total_nodes = Enum.count(nodes)
    req_per_node = div(n, total_nodes)
    nodes
      |> Enum.flat_map(fn node ->
        1..req_per_node
          |> Enum.map(fn _ -> 
            Task.Supervisor.async({Blitzy.TasksSupervisor, node}, Blitzy.Worker, :start, [url])
          end)
        end)
      |> Enum.map(&Task.await(&1, :infinity))
      |> parse_res
  end
  
  defp parse_res(res) do
    {succeeded, failures} = 
      Enum.split_with(res, fn x ->
        case x do
          {:ok, _} -> true
          _        -> false
        end   
      end)
    total_workers = Enum.count(res)
    total_success = Enum.count(succeeded)
    total_fail    = Enum.count(failures)
    data = succeeded |> Enum.map(fn {:ok, time} -> time end)
    avg_time = average(data)
    long_time = Enum.max(data)
    short_time = Enum.min(data)

    IO.puts """
    Total workers     : #{total_workers}
    Succesful reqs    : #{total_success}
    Failed reqs       : #{total_fail}
    Avg (ms)          : #{avg_time}
    Longest (ms)      : #{long_time}
    Shortest (ms)     : #{short_time}
    """
  end

  defp average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end

  defp do_help do
    IO.puts """
    Usage:
    blitzy -n [requests] [url]
  
    Options:
    -n, [--requests]      # Number of requests
  
    Example:
    ./blitzy -n 100 http://www.bieberfever.com
    """
    System.halt(0)
  end
  

end