defmodule WorldBeatsWeb.ProfileLive do
  use WorldBeatsWeb, :live_view

  # alias LiveBeats.{Accounts}
  # alias WorldBeatsWeb.Presence
  # alias WorldBeatsWeb.ProfileLive.{UploadFormComponent}

  # @max_presences 20

  def render(assigns) do
    ~H"""
    <div>
      <h1>Welcome User <%= @current_user.email %></h1>
    </div>
    """
  end

  def mount(%{"profile_username" => _profile_username}, _session, socket) do
    # %{current_user: current_user} = socket.assigns

    # profile_user =
    #   if current_user.username == profile_username do
    #     current_user
    #   else
    #     Accounts.get_user_by!(username: profile_username)
    #   end

    {:ok, socket, temporary_assigns: [presences: %{}]}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Listing Songs")
    |> assign(:song, nil)
  end
end
