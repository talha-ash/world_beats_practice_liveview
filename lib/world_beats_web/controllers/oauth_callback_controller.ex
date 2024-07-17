defmodule WorldBeatsWeb.OAuthCallbackController do
  use WorldBeatsWeb, :controller
  require Logger

  alias WorldBeats.Accounts

  def new(conn, %{"provider" => "github", "code" => code, "state" => state}) do
    client = github_client(conn)

    with {:ok, info} <- client.exchange_access_token(code: code, state: state),
         %{info: info, primary_email: primary, emails: emails, token: token} = info,
         {:ok, user} <- Accounts.register_github_user(primary, info, emails, token) do
      conn
      |> put_flash(:info, "Welcome #{user.email}")
      |> WorldBeatsWeb.UserAuth.log_in_user(user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.info("failed GitHub insert #{inspect(changeset.errors)}")

        conn
        |> put_flash(
          :error,
          "We were unable to fetch the necessary information from your GithHub account"
        )
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.info("failed GitHub exchange #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to contact GitHub. Please try again later")
        |> redirect(to: "/")
    end
  end

  def new(conn, %{"provider" => "github", "error" => "access_denied"}) do
    redirect(conn, to: "/")
  end

  def sign_out(conn, _) do
    WorldBeatsWeb.UserAuth.log_out_user(conn)
  end

  defp github_client(conn) do
    conn.assigns[:github_client] || WorldBeats.Github
  end
end
