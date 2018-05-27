defmodule ExAviso.Qiita do

	@default_get_my_items_option %{"page" => 1, "per_page" => 20}
	@default_get_items_option %{"user" => "", "page" => 1, "per_page" => 20}
	@default_get_tag_items_option %{"page" => 1, "per_page" => 20}

  def callback_handle_get_my_items(:message, _) do
		:ok
	end

  def callback_handle_get_my_items(:desktop_notification, m) do
    text = String.split(m.content, "\n")
    |> get_my_items()
    {:send, %ExAviso.SlackRequest{
      type: "message",
      channel: m.channel,
      text: Enum.join(text, "\n"),
      ts: DateTime.to_unix(DateTime.utc_now()),
    }}
  end

  def callback_handle_get_items(:message, _) do
		:ok
	end

  def callback_handle_get_items(:desktop_notification, m) do
    text = String.split(m.content, "\n")
    |> get_items()

    {:send, %ExAviso.SlackRequest{
      type: "message",
      channel: m.channel,
      text: Enum.join(text, "\n"),
      ts: DateTime.to_unix(DateTime.utc_now()),
    }}
  end

  def callback_handle_get_tag_items(:message, _) do
		:ok
	end

  def callback_handle_get_tag_items(:desktop_notification, m) do
    text = String.split(m.content, "\n")
    |> get_tag_items()

    {:send, %ExAviso.SlackRequest{
      type: "message",
      channel: m.channel,
      text: Enum.join(text, "\n"),
      ts: DateTime.to_unix(DateTime.utc_now()),
    }}
  end

  def get_items([]) do
    []
  end

  def get_items([head| []]) do
    if Regex.match?(~r/getItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_get_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/users/#{option["user"]}/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{status_code: 404} = error ->
          IO.inspect error
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      [Enum.join(e, "\n")]
    else
      [""]
    end
  end

  def get_items([head| tail]) do
    resp = if Regex.match?(~r/getItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/users/#{option["user"]}/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      Enum.join([e|["----------------------------------------"]], "\n")
    else
      ""
    end
    [resp| get_items(tail)]
  end

  def get_my_items([]) do
    []
  end

  def get_my_items([head| []]) do
    if Regex.match?(~r/getMyItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_get_my_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/authenticated_user/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      [Enum.join(e, "\n")]
    else
      [""]
    end
  end

  def get_my_items([head| tail]) do
    resp = if Regex.match?(~r/getMyItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_get_my_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/authenticated_user/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      Enum.join([e|["----------------------------------------"]], "\n")
    else
      ""
    end
    [resp| get_my_items(tail)]
  end

  def get_tag_items([]) do
    []
  end

  def get_tag_items([head| []]) do
    if Regex.match?(~r/getTagItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_get_tag_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/tags/#{option["tag"]}/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      [Enum.join(e, "\n")]
    else
      [""]
    end
  end

  def get_tag_items([head| tail]) do
    resp = if Regex.match?(~r/getTagItems/, head) do
			option = ExAviso.Slack.get_option(head, @default_get_tag_items_option)

      [token: token] = Application.get_all_env(:qiita) 
      headers = [{"Authorization", "Bearer #{token}"}]
      url = "https://qiita.com/api/v2/tags/#{option["tag"]}/items?page=#{option["page"]}&per_page=#{option["per_page"]}"
      body = case HTTPoison.get!(url, headers) do
        %{status_code: 200, body: body} ->
          Poison.Parser.parse!(body, keys: :atoms)
        %{error: "account_inactive"} = error ->
          IO.inspect error
      end
     
      e = for %{title: title, url: url} <- body, do: "#{title}[#{url}]"
      Enum.join([e|["----------------------------------------"]], "\n")
    else
      ""
    end
    [resp| get_tag_items(tail)]
  end
end

