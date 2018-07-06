class TravelPostLikeController < ApplicationController
  before_action :authenticate_user!


  def create
    param_like = params[:like]
    post_id = params[:travel_post_id]
    user_id = current_user.id

    like = param_like == 'like' ? true : false

    @travel_post_like = TravelPostLike.new(like: like, travel_post_id: post_id, user_id: user_id)

    respond_to do |format|
      if @travel_post_like.save
        format.html { redirect_to travel_posts_path, notice: '좋아요를 눌렀습니다.' }
      else
        format.html { redirect_to travel_posts_path, error: '오류가 발생했습니다.' }
      end
    end
  end

  def destroy
    param_like = params[:like]
    post_id = params[:id]
    user_id = current_user.id

    like = param_like == 'like' ? true : false

    @travel_post_like = TravelPostLike.where(like: like, travel_post_id: post_id, user_id: user_id).first

    respond_to do |format|
      if @travel_post_like.destroy
        format.html { redirect_to travel_posts_path, notice: '좋아요를 취소되었습니다.' }
      else
        format.html { redirect_to travel_posts_path, error: '오류가 발생했습니다.' }
      end
    end
  end
end
