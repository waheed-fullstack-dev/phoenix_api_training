defmodule PhoenixApi.Plugs.Authorize do
  @behaviour Plug

  import Plug.Conn
  alias PhoenixApi.Guardian
  def init(default), do: default

  def call(conn, _) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      conn
    else
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(423, Jason.encode!(%{errors: error}))
        |> Plug.Conn.halt()

      _r ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(423, Jason.encode!(%{errors: ["Permission Denied"]}))
        |> Plug.Conn.halt()
    end
  end

end
