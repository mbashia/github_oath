defmodule GithubOath.Repo do
  use Ecto.Repo,
    otp_app: :github_oath,
    adapter: Ecto.Adapters.Postgres
end
