defmodule PhoenixApiWeb.UserController do
  use PhoenixApiWeb, :controller

  alias PhoenixApi.Accounts
  alias PhoenixApi.Accounts.User
  alias PhoenixApi.Guardian

  action_fallback PhoenixApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email(email) do
      %User{} = user ->
        if PhoenixApi.Accounts.User.valid_password?(user, password) do

          {:ok, token, _} = Guardian.encode_and_sign(user)
          conn
          |> put_status(:ok)
          |> put_resp_header("location", ~p"/api/users/#{user}")
          |> render(:login, user: user, token: token)
        else
          conn
          |> put_status(:not_found)
          |> render(:login)
        end
      _ ->
        conn
        |> put_status(:not_found)
        |> render(:login)
      end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
