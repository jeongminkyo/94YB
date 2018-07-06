class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter(only: [:index, :show, :edit, :update, :destroy]) do
    user = User.find_by_id(current_user.id)
    unless user.is_member? || user.is_admin?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end
  # GET /posts
  # GET /posts.json
  def index
    page = params[:page].blank? ? 1 : params[:page]

    where_clause = Post.make_where_clause(params)

    @posts = Post.find_post_list(page, where_clause)

    respond_to do |format|
      format.html
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post_attachments = @post.post_attachments.all
    @post_like = PostLike.where(post_id: params[:id], like: true).count
    @post_dislike = PostLike.where(post_id: params[:id], like: false).count
    @current_user_like = PostLike.where(post_id: params[:id], like: true, user_id: current_user.id)
    @current_user_dislike = PostLike.where(post_id: params[:id], like: false, user_id: current_user.id)
  end

  # GET /posts/new
  def new
    @post = Post.new
    @post_attachment = @post.post_attachments.build
  end

  # GET /posts/1/edit
  def edit
    authorize_action_for @post
  end

  # POST /posts
  # POST /posts.json
  def create
    params[:post][:user_id] = current_user.id
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        if params[:post_attachments].present?
          params[:post_attachments]['s3'].each do |a|
            @post_attachment = @post.post_attachments.create!(:s3 => a, :post_id => @post.id)
          end
        end
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    authorize_action_for @post
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    authorize_action_for @post
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :context, :user_id, post_attachments_attributes: [:id, :post_id, :s3])
    end
end
