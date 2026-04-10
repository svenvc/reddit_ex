defmodule Reddit.Utils do
  def validate_url_and_extract_html_title(url) when is_binary(url) do
    case Req.get(url) do
      {:ok, %Req.Response{status: 200, headers: %{"content-type" => ["text/html" <> _more]}, body: body}} ->
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
  end
end
