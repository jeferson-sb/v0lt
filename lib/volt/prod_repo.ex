defmodule Volt.ProdRepo do
  use Ecto.Repo,
    otp_app: :volt,
    adapter: Ecto.Adapters.Postgres
end
