class SessionsController < ApplicationController
  def new
  end

  def create
    # user = authenticate_session(session_params)
    user = warden.authenticate(:oath_lockable)

    if sign_in(user)
      redirect_to posts_path
    else
      redirect_to root_path, notice: "Invalid email or password"
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end

