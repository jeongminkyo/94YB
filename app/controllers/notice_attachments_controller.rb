class NoticeAttachmentsController < ApplicationController
  before_action :set_notice_attachment, only: [:show, :edit, :update, :destroy]

  # GET /notice_attachments
  # GET /notice_attachments.json
  def index
    @notice_attachments = NoticeAttachment.all
  end

  # GET /notice_attachments/1
  # GET /notice_attachments/1.json
  def show
  end

  # GET /notice_attachments/new
  def new
    @notice_attachment = NoticeAttachment.new
  end

  # GET /notice_attachments/1/edit
  def edit
  end

  # POST /notice_attachments
  # POST /notice_attachments.json
  def create
    @notice_attachment = NoticeAttachment.new(notice_attachment_params)

    respond_to do |format|
      if @notice_attachment.save
        format.html { redirect_to @notice_attachment, notice: 'Notice attachment was successfully created.' }
        format.json { render :show, status: :created, location: @notice_attachment }
      else
        format.html { render :new }
        format.json { render json: @notice_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notice_attachments/1
  # PATCH/PUT /notice_attachments/1.json
  def update
    respond_to do |format|
      if @notice_attachment.update(notice_attachment_params)
        format.html { redirect_to @notice_attachment, notice: 'Notice attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @notice_attachment }
      else
        format.html { render :edit }
        format.json { render json: @notice_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notice_attachments/1
  # DELETE /notice_attachments/1.json
  def destroy
    @notice_attachment.destroy
    respond_to do |format|
      format.html { redirect_to notice_attachments_url, notice: 'Notice attachment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice_attachment
      @notice_attachment = NoticeAttachment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notice_attachment_params
      params.require(:notice_attachment).permit(:notice_id, :s3)
    end
end
