module Api::V1
  class UsersController < ApplicationController

    # GET /api/v1/user_list
    def user_list
      @users = User.user_list

      render json: @users
    end
  end
end