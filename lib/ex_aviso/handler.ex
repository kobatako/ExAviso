defmodule ExAviso.Handler do
  use Behaviour

  @callback callback_handle(atom, ExAviso.SlackResponse) :: :ok | {:send, message :: String.t}
end

