defmodule ExAviso.Slack do
  @moduledoc """
  Documentation for ExAviso.Supervisor.
  """

  import Supervisor.Spec
	use GenServer
  use Task
  alias ExAviso.SlackResponse

  def start_link(token) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
    Task.start_link(__MODULE__, :connect, [token])
  end

  def init() do
    {:ok, %{}}
  end

  @doc """
  connect slack.

  """
  def connect(token) do
		fetch_body(token)
		|> parse_url()
		|> connect_websocket()
    |> loop()
  end

  defp fetch_body(token) do
    url = "https://slack.com/api/rtm.start?token=#{token}&include_locale=true"
    case HTTPoison.get! url do
			%{status_code: 200, body: body} ->
				Poison.Parser.parse!(body, keys: :atoms)
      %{error: "account_inactive"} = error ->
				IO.inspect error
		end
	end

	defp parse_url(%{url: url}) do
		with %{"uri" => uri} <- Regex.named_captures(~r/wss:\/\/(?<uri>.*)/, url),
					[domain| path] <- String.split(uri, "/") do
			%{domain: domain, path: Enum.join(path, "/")}
		end
	end

	defp connect_websocket(%{domain: domain, path: path}) do
		Socket.Web.connect!(domain, secure: true, path: "/" <> path)
	end

	defp loop(socket) do
		case socket |> Socket.Web.recv!() do
			{:text, text} ->
        Poison.Parser.parse!(text, keys: :atoms)
				|> message(socket)
				loop(socket)
			{:ping, _} ->
        t = DateTime.utc_now() |> DateTime.to_string()
				socket |> Socket.Web.send!({:text, Poison.encode!(%{type: "ping", id: t})})
				loop(socket)
			other ->
				IO.inspect "other request"
				IO.inspect other
		end
	end

	defp message(%{type: "desktop_notification"} = m, socket) do
    {ts, _} = Integer.parse(m.event_ts)
    r = %SlackResponse{from: m.title, content: m.content, channel: m.channel,
          ts: DateTime.to_string(DateTime.from_unix!(ts))
    }
    Enum.map(GenServer.call(__MODULE__, :fetch), fn f -> f.(:desktop_notification, r) end)
    |> response_handle(socket)
	end

	defp message(%{type: "message"} = m, socket) do
    {ts, _} = Integer.parse(m.ts)
    r = %SlackResponse{from: m.user, text: m.text, channel: m.channel,
          ts: DateTime.to_string(DateTime.from_unix!(ts))
    }
    Enum.map(GenServer.call(__MODULE__, :fetch), fn f -> f.(:message, r) end)
    |> response_handle(socket)
	end

	defp message(%{type: type} = message, _) do
	end

	defp message(%{ok: true} = message, _) do
	end

  @doc """
    
  """
  def handle_cast({:push, func}, t) when is_function(func, 2) do
    {:noreply, [func|t]}
  end

  def handle_cast({:push, _}, t) do
    {:noreply, t}
  end

  def handle_call(:fetch, _from, t) do
    {:reply, t, t}
  end

  def response_handle([], _) do
  end

  def response_handle([head| []], socket) do
    response(head, socket)
  end

  def response_handle([head| tail], socket) do
    response(head, socket)
    response_handle(tail, socket) 
  end

  def response({:send, message}, socket) do
    socket |> Socket.Web.send!({:text, Poison.encode!(message)})
  end

  def response(:ok, _) do
  end

  def response(_other, _) do
  end

	def get_option(line, default) do
		String.split(line, " ")
		|> Enum.map(&Regex.named_captures(~r/(?<name>.*)=(?<value>.*)/, &1)) # オプションとして記載されているものの取得
		|> Enum.filter(&(&1 != nil)) # nilを削除
		|> Enum.map(&(%{&1["name"] => &1["value"]})) # name = valueでオプションを指定しているので%{name => value}でmapを作成
		|> Enum.reduce(%{}, &(Map.merge(&1, &2))) # 配列内にあるmapを連結
		|> Map.merge(default, fn _k, v1, _v2 -> v1 end) # 優先度を第一引数のmapにする
	end
end

