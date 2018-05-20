defmodule ExAviso.Supervisor do
  @moduledoc """
  Documentation for ExAviso.Supervisor.
  """
  use Supervisor

  def start_link(_) do
    [token: token] = Application.get_all_env(:slack) 
    children = [
      worker(Task, [ExAviso.Slack, :connect, [token]])
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end

  def init([]) do
  end
end

