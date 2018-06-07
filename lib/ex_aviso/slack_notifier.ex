defmodule ExAviso.SlackNotifier do
  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, name: __MODULE__)
  end

  def init(socket) do
    {:ok, %{:socket => socket}}
  end

  def handle_cast({:notification, message}, t) do
    t.socket |> Socket.Web.send!({:text, Poison.encode!(message)})
    {:noreply, t}
  end
end
