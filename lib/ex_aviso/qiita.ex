defmodule ExAviso.Qiita do
  @behaviour ExAviso.Handler

  def callback_handle(:message, m) do
    :ok
  end

  def callback_handle(:desktop_notification, m) do
    [token: token] = Application.get_all_env(:qiita) 
    headers = [{"Authorization", "Bearer #{token}"}]
    url = "https://qiita.com/api/v2/authenticated_user/items?page=1&per_page=20"
    response = HTTPoison.get!(url, headers)
    IO.inspect response
    {:send, %ExAviso.SlackRequest{
      type: "message",
      channel: m.channel,
      text: "<@kobaru> RTM Bot!! \n change word",
      ts: DateTime.to_unix(DateTime.utc_now()),
    }}
  end
end

