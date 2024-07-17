defmodule WorldBeatsWeb.Router do
  use WorldBeatsWeb, :router

  import WorldBeatsWeb.UserAuth,
    only: [redirect_if_user_is_authenticated: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WorldBeatsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WorldBeatsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    get "/oauth/callbacks/:provider", OAuthCallbackController, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", WorldBeatsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:world_beats, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WorldBeatsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", WorldBeatsWeb do
    pipe_through :browser

    # get "/", RedirectController, :redirect_authenticated
    # get "/files/:id", FileController, :show

    delete "/signout", OAuthCallbackController, :sign_out

    live_session :default, on_mount: [{WorldBeatsWeb.UserAuth, :current_user}] do
      live "/signin", SignInLive, :index
    end

    live_session :authenticated,
      on_mount: [{WorldBeatsWeb.UserAuth, :ensure_authenticated}] do
      live "/:profile_username", ProfileLive, :show
    end
  end
end
