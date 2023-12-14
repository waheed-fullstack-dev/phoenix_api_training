defmodule PhoenixApi.Plugs.CurrentUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    current_token = Enum.into(conn.req_headers, %{}) |> parse()
    saved_data = PhoenixApi.Accounts.get_user!(current_user.id)

    IO.inspect(saved_data, label: "saved_data")

    cond do
      current_token in saved_data ->
        conn |> assign(:current_user, current_user)

      saved_data == [] ->
        conn
        |> send_resp(
          :locked,
          Jason.encode!(%{
            authenticated: false,
            message: "You were logged out, please login again!",
            result: []
          })
        )
        |> halt

      current_token not in saved_data ->
        conn
        |> send_resp(
          :locked,
          Jason.encode!(%{
            authenticated: false,
            message: "You are not authenticated.",
            result: []
          })
        )
        |> halt

      true ->
        conn
        |> send_resp(
          :locked,
          Jason.encode!(%{authenticated: false, message: "Unknown error occurred.", result: []})
        )
        |> halt
    end
  end

  defp parse(%{"authorization" => "Bearer " <> id}), do: id
end
