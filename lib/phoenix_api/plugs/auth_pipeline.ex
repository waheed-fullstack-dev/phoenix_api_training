defmodule PhoenixApi.Plugs.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :phoenix_api,
    module: PhoenixApi.Guardian,
    error_handler: PhoenixApiWeb.AuthErrorController

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
