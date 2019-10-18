class SessionsController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]

  def new; end

  def create
    warden.authenticate!(:oath_lockable)
    redirect_to posts_path, notice: 'You are signed in'

    # user = authenticate_session(session_params)
    # if sign_in(user)
    #   redirect_to posts_path
    # else
    #   redirect_to root_path, notice: "Invalid email or password"
    # end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
