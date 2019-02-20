defmodule Blitzy.Worker do
  use Timex
  require Logger

  def start(url) do
    IO.puts "Running on node #node-#{node}"
    {timestamp, res} = Duration.measure(
      fn -> HTTPoison.get(url) end
    )
    handle_res({Duration.to_milliseconds(timestamp), res})
  end

  defp handle_res({ms, {:ok, %HTTPoison.Response{status_code: code}}}) 
  when code >= 200 and code <= 304 do
    Logger.info "worker [#{node}-#{inspect self}] completed in #{ms} ms."
    {:ok, ms}
  end
  defp handle_res({_ms, {_, %HTTPoison.Error{reason: r}}}) do
    Logger.info "worker [#{node}-#{inspect self}] error, reason: #{r}."
    {:error, r}
  end
  defp handle_res({_ms, _}) do
    Logger.info "worker [#{node}-#{inspect self}] error, reason: unknown."
    {:error, :unknown}
  end
end