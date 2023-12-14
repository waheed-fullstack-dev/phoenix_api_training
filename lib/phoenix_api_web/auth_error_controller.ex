defmodule PhoenixApiWeb.AuthErrorController do
  import Plug.Conn

  @spec auth_error(Plug.Conn.t(), {any(), any()}, any()) :: Plug.Conn.t()
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    send_resp(conn, 401, body)
  end
end
