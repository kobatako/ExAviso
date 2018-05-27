defmodule ExAviso.Supervisor do
  @moduledoc """
  Documentation for ExAviso.Supervisor.
  """
  import Supervisor.Spec
	use GenServer

  def start_link() do
    [token: token] = Application.get_all_env(:slack) 
    children = [
      worker(ExAviso.Slack, [token])
    ]
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
		{:ok, pid}
  end

	@impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:push, func}, t) when is_function(func) do
    GenServer.cast(ExAviso.Slack, {:push, func})
		{:noreply, [func | t]}
  end

  @impl true
  def handle_cast({:push, _}, t) do
		{:noreply, t}
  end
end

