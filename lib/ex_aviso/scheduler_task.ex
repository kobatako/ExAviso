defmodule ExAviso.Scheduler.Task do
  alias ExAviso.SlackRequest, as: Request
  alias ExAviso.DataStorage, as: Storage

  def tag_items() do
    Storage.first(:tags)
    [token: token] = Application.get_all_env(:qiita)
    headers = [{"Authorization", "Bearer #{token}"}]
    channels = GenServer.call(ExAviso.Slack, {:channels})
    message = fetch_tag_items(Storage.all(:tags), headers, channels)
  end

  def fetch_tag_items([], _, _) do
  end

  def fetch_tag_items([{id, tag, channel, per_page} | tail], headers, channels) do
    c = Enum.find(channels, fn c -> c.name == channel end)
    url = "https://qiita.com/api/v2/tags/#{tag}/items?page=1&per_page=#{per_page}"

    body =
      case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)

        %{error: "account_inactive"} = error ->
          IO.inspect(error)
      end

    e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"

    m = %Request{
      type: "message",
      channel: c.id,
      text: Enum.join([" ---- tag is [#{tag}] --- - "] ++ e, "\n"),
      ts: DateTime.utc_now() |> DateTime.to_unix()
    }

    GenServer.cast(ExAviso.Slack, {:notification, m})
    fetch_tag_items(tail, headers, channels)
  end
end
