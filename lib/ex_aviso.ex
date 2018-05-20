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
          start: {ExAviso.Supervisor, :start_link, [%{}]}
       }
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

