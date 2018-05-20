defmodule ExAviso.Slack do
  @moduledoc """
  Documentation for ExAviso.Supervisor.
  """

  @doc """
  connect slack.

  """
  def connect(token) do
		fetch_body(token)
		|> parse_url
		|> connect_websocket
    |> loop
  end

  def fetch_body(token) do
    url = "https://slack.com/api/rtm.start?token=" <> token <> "&include_locale=true"
    case HTTPoison.get! url do
			%{status_code: 200, body: body} ->
				Poison.Parser.parse!(body, keys: :atoms)
		end
	end

	defp parse_url(%{url: url}) do
		with %{"uri" => uri} <- Regex.named_captures(~r/wss:\/\/(?<uri>.*)/, url),
					[domain| path] <- String.split(uri, "/") do
			%{domain: domain, path: Enum.join(path, "/")}
		else
			_ ->
				%{error: "error"}
		end
	end

	defp connect_websocket(%{domain: domain, path: path}) do
		Socket.Web.connect! domain, secure: true, path: "/" <> path
	end

	def loop(socket) do
		case socket |> Socket.Web.recv! do
			{:text, text} ->
        Poison.Parser.parse!(text, keys: :atoms)
				|> message(socket)
				loop(socket)
			{:ping, _} ->
				IO.inspect "ping pong"
        t = DateTime.utc_now |> DateTime.to_string
				socket |> Socket.Web.send! {:text, Poison.encode!(%{type: "ping", id: t})}		
				loop(socket)
			other ->
				IO.inspect "hoge"
				IO.inspect other
		end
	end

	defp message(%{type: "desktop_notification"} = message, _) do
		IO.inspect "desktop_notification"
		IO.inspect "get message"
		IO.inspect message
	end

	defp message(%{type: "message"} = message, _) do
		IO.inspect "message"
		IO.inspect "get message"
		IO.inspect message
	end

	defp message(%{type: type} = message, _) do
		IO.inspect type
		IO.inspect message
	end
end

