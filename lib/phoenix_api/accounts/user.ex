defmodule PhoenixApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w|
  first_name
  last_name
  email
  user_password
  |a

  @optional_fields ~w|
  id
  age
  is_active
  city
  address
  state
  postal_code
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :age, :integer
    field :user_password, :string, virtual: true, redact: true
    field :password, :string, redact: true
    field :is_active, :boolean
    field :address, :string
    field :city, :string
    field :state, :string
    field :postal_code, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:user_password])
    |> validate_length(:user_password, min: 8, max: 72)
    # Examples of additional user_password validation:
    |> validate_format(:user_password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:user_password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:user_password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :password, true)
    password = get_change(changeset, :user_password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:user_password, max: 72, count: :bytes)
      |> put_change(:password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:user_password)
    else
      changeset
    end
  end

  def valid_password?(%PhoenixApi.Accounts.User{password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end
end
