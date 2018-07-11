class NoticesController < ApplicationController
  before_action :set_notice, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter(only: [:index, :show]) do
    user = User.find_by_id(current_user.id)
    unless user.is_member? || user.is_admin? || user.is_manager?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end
  before_filter(only: [:edit, :update, :new, :create, :destroy]) do
    user = User.find_by_id(current_user.id)
    unless user.is_admin? || user.is_manager?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end

  # GET /notices
  # GET /notices.json
  def index
    page = params[:page].blank? ? 1 : params[:page]

    @notices = Notice.find_notice_list(page)
  end

  # GET /notices/1
  # GET /notices/1.json
  def show
  end

  # GET /notices/new
  def new
    @notice = Notice.new
    @notice_attachment = @notice.notice_attachments.build
  end

  # GET /notices/1/edit
  def edit
  end

  # POST /notices
  # POST /notices.json
  def create
    params[:notice][:user_id] = current_user.id
    @notice = Notice.new(notice_params)

    respond_to do |format|
      if @notice.save
        if params[:notice_attachments].present?
          params[:notice_attachments]['s3'].each do |a|
            @notice_attachment = @notice.notice_attachments.create!(:s3 => a, :notice_id => @notice.id)
          end
        end
        format.html { redirect_to notices_path, notice: 'Notice was successfully created.' }
        format.json { render :show, status: :created, location: @notice }
      else
        format.html { render :new }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notices/1
  # PATCH/PUT /notices/1.json
  def update
    respond_to do |format|
      if @notice.update(notice_params)
        format.html { redirect_to @notice, notice: 'Notice was successfully updated.' }
        format.json { render :show, status: :ok, location: @notice }
      else
        format.html { render :edit }
        format.json { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notices/1
  # DELETE /notices/1.json
  def destroy
    @notice.destroy
    respond_to do |format|
      format.html { redirect_to notices_url, notice: 'Notice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notice_params
      params.require(:notice).permit(:title, :context, :user_id, notice_attachments_attributes:
          [:id, :notice_id, :s3])
    end
end
