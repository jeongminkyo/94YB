class PostLikeController < ApplicationController
  before_action :authenticate_user!

  def create
    param_like = params[:like]
    post_id = params[:post_id]
    user_id = current_user.id

    like = param_like == 'like' ? true : false

    @post_like = PostLike.new(like: like, post_id: post_id, user_id: user_id)

    respond_to do |format|
      if @post_like.save
        format.html { redirect_to post_path(post_id), notice: '좋아요를 눌렀습니다.' }
      else
        format.html { redirect_to post_path(post_id), error: '오류가 발생했습니다.' }
      end
    end
  end

  def destroy
    param_like = params[:like]
    post_id = params[:post_id]
    user_id = current_user.id

    like = param_like == 'like' ? true : false

    @post_like = PostLike.where(like: like, post_id: post_id, user_id: user_id).first

    respond_to do |format|
      if @post_like.destroy
        format.html { redirect_to post_path(post_id), notice: '좋아요를 취소되었습니다.' }
      else
        format.html { redirect_to post_path(post_id), error: '오류가 발생했습니다.' }
      end
    end
  end

end
