class TravelPostsController < ApplicationController
  before_action :set_travel_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter(only: [:index, :show, :edit, :update, :destroy]) do
    user = User.find_by_id(current_user.id)
    unless user.is_member? || user.is_admin? || user.is_manager?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end
  # GET /travel_posts
  # GET /travel_posts.json
  def index
    page = params[:page].blank? ? 1 : params[:page]

    where_clause = TravelPost.make_where_clause(params)

    @travel_posts = TravelPost.find_travel_post_list(page, where_clause)
  end

  # GET /travel_posts/1
  # GET /travel_posts/1.json
  def show
  end

  # GET /travel_posts/new
  def new
    @travel_post = TravelPost.new
    @travel_post_attachment = @travel_post.travel_post_attachments.build

  end

  # GET /travel_posts/1/edit
  def edit
  end

  # POST /travel_posts
  # POST /travel_posts.json
  def create
    params[:travel_post][:user_id] = current_user.id
    @travel_post = TravelPost.new(travel_post_params)

    respond_to do |format|
      if @travel_post.save
        if params[:travel_post_attachments].present?
          params[:travel_post_attachments]['s3'].each do |a|
            @travel_post_attachment = @travel_post.travel_post_attachments.create!(:s3 => a, :travel_post_id => @travel_post.id)
          end
        end
        format.html { redirect_to travel_posts_path, notice: 'Travel post was successfully created.' }
        format.json { render :show, status: :created, location: @travel_post }
      else
        format.html { render :new }
        format.json { render json: @travel_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /travel_posts/1
  # PATCH/PUT /travel_posts/1.json
  def update
    respond_to do |format|
      if @travel_post.update(travel_post_params)
        format.html { redirect_to @travel_post, notice: 'Travel post was successfully updated.' }
        format.json { render :show, status: :ok, location: @travel_post }
      else
        format.html { render :edit }
        format.json { render json: @travel_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_posts/1
  # DELETE /travel_posts/1.json
  def destroy
    @travel_post.destroy
    respond_to do |format|
      format.html { redirect_to travel_posts_url, notice: 'Travel post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_travel_post
      @travel_post = TravelPost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def travel_post_params
      params.require(:travel_post).permit(:title, :context, :user_id, travel_post_attachments_attributes:
          [:id, :travel_post_id, :s3])
    end
end
