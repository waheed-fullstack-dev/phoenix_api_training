defmodule PhoenixApiWeb.Router do
  use PhoenixApiWeb, :router
  use Plug.ErrorHandler

  alias PhoenixApi.Plugs.AuthPipeline

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug(AuthPipeline)
    plug(PhoenixApi.Plugs.Authorize)
  end

  pipeline :current_user do
    plug(AuthPipeline)
    plug(PhoenixApi.Plugs.CurrentUser)
  end

  scope "/api", PhoenixApiWeb do
    pipe_through :api

    post "/user/sign_in", UserController, :sign_in
  end

  scope "/api", PhoenixApiWeb do
    pipe_through [:api, :authenticated]

    resources "/users", UserController, except: [:new, :edit]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:phoenix_api, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
