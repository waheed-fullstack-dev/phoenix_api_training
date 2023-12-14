defmodule PhoenixApiWeb.UserJSON do
  alias PhoenixApi.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  def login(%{user: user, token: token}) do
    %{user: data(user), access_token: token}
  end

  def login(_) do
    %{
      error: 404,
      message: "No user found for this email"
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      age: user.age
    }
  end
end
