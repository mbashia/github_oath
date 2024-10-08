defmodule GithubOathWeb.AuthController do
  use GithubOathWeb, :controller
  alias GithubOath.Accounts.User
  alias GithubOath.Repo
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    user_data = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}

    case findOrCreateUser(user_data) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to OAuth Tutorial!")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: "/")
    end
  end

  # Handle authentication failure
  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    conn
    |> put_flash(
      :error,
      "Authentication failed: #{Enum.map(failure.errors, & &1.message) |> Enum.join(", ")}"
    )
    |> redirect(to: "/")
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  defp findOrCreateUser(user_data) do
    changeset = User.changeset(%User{}, user_data)

    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        IO.puts("User not found, creating new one")
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
