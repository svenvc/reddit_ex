defmodule Reddit.Utils do
  alias Swoosh.Email

  def validate_url_and_extract_html_title(url) when is_binary(url) do
    case validate_url(url) do
      {:ok, url} ->
        case Req.get(url) do
          {:ok,
           %Req.Response{
             status: 200,
             headers: %{"content-type" => ["text/html" <> _more]},
             body: body
           }} ->
            body
            |> Floki.parse_document!()
            |> Floki.find("title")
            |> List.first()
            |> Floki.text()
            |> String.trim()
            |> String.split()
            |> Enum.join(" ")
            |> then(&{:ok, &1})

          _ ->
            {:error, "failed to resolve url and find html title"}
        end

      {:error, msg} ->
        {:error, msg}
    end
  end

  def validate_url(url) when is_binary(url) do
    case URI.new(url) do
      {:ok, uri} ->
        if uri.scheme in ~w(http https) && uri.host != "" do
          {:ok, uri}
        else
          {:error, "malformed/unsupported url"}
        end

      {:error, _error} ->
        {:error, "malformed url"}
    end
  end

  def get_google_access_token(client_id, client_secret, refresh_token) do
    {:ok, %Req.Response{status: 200, body: %{"access_token" => access_token}}} =
      Req.post("https://oauth2.googleapis.com/token",
        form: [
          client_id: client_id,
          client_secret: client_secret,
          refresh_token: refresh_token,
          grant_type: :refresh_token
        ],
        retry: :transient
      )

    access_token
  end

  def get_google_access_token() do
    client_id = System.get_env("GOOGLE_CLIENT_ID")
    client_secret = System.get_env("GOOGLE_CLIENT_SECRET")
    refresh_token = System.get_env("GOOGLE_REFRESH_TOKEN")
    get_google_access_token(client_id, client_secret, refresh_token)
  end

  def deliver_gmail(email) do
    access_token = get_google_access_token()
    Reddit.Mailer.deliver(email, access_token: access_token)
  end

  def new_test_email(to) do
    Email.new()
    |> Email.to(to)
    |> Email.from({"Reddit_ex", "sven@stfx.eu"})
    |> Email.subject("Reddit_ex | Test Email")
    |> Email.text_body(
      "This is a test email from Reddit_ex.\n\nCreated at #{DateTime.utc_now()} with UUID #{Ecto.UUID.generate()}. "
    )
  end
end
