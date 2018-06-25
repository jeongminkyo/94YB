class RegisterController < ApplicationController
  def info

  end

  def create
    user = User.find(current_user.id)

    respond_to do |format|
      if user.update(:display_name => params[:name])
        format.html { redirect_to root_path }
      else
        format.html { redirect_to register_info_path }
      end
    end
  end
end
