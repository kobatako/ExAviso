defmodule ExAviso do
  @moduledoc """
  Documentation for ExAviso.
  """
  use Supervisor

  def start(_type, _args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
			%{
				id: ExAviso.Supervisor,
				start: {ExAviso.Supervisor, :start_link, []},
				type: :supervisor
      }
    ]
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
		IO.inspect Supervisor.count_children(pid)
		{:ok, pid}
  end

  def add_event_handler(func) do
    GenServer.cast(ExAviso.Supervisor, {:push, func})
  end
  def get_event_handler() do
    GenServer.call(ExAviso.Supervisor, :fetch)
  end

  def add_qiita_handler() do
    add_event_handler(fn x,y -> ExAviso.Qiita.callback_handle_get_my_items(x, y) end)
    # TODO :後日実装
    add_event_handler(fn x,y -> ExAviso.Qiita.callback_handle_get_items(x, y) end)
  end
end

