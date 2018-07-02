class TravelPostAttachmentsController < ApplicationController
  before_action :set_travel_post_attachment, only: [:show, :edit, :update, :destroy]

  # GET /travel_post_attachments
  # GET /travel_post_attachments.json
  def index
    @travel_post_attachments = TravelPostAttachment.all
  end

  # GET /travel_post_attachments/1
  # GET /travel_post_attachments/1.json
  def show
  end

  # GET /travel_post_attachments/new
  def new
    @travel_post_attachment = TravelPostAttachment.new
  end

  # GET /travel_post_attachments/1/edit
  def edit
  end

  # POST /travel_post_attachments
  # POST /travel_post_attachments.json
  def create
    @travel_post_attachment = TravelPostAttachment.new(travel_post_attachment_params)

    respond_to do |format|
      if @travel_post_attachment.save
        format.html { redirect_to @travel_post_attachment, notice: 'Travel post attachment was successfully created.' }
        format.json { render :show, status: :created, location: @travel_post_attachment }
      else
        format.html { render :new }
        format.json { render json: @travel_post_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /travel_post_attachments/1
  # PATCH/PUT /travel_post_attachments/1.json
  def update
    respond_to do |format|
      if @travel_post_attachment.update(travel_post_attachment_params)
        format.html { redirect_to @travel_post_attachment, notice: 'Travel post attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @travel_post_attachment }
      else
        format.html { render :edit }
        format.json { render json: @travel_post_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_post_attachments/1
  # DELETE /travel_post_attachments/1.json
  def destroy
    @travel_post_attachment.destroy
    respond_to do |format|
      format.html { redirect_to travel_post_attachments_url, notice: 'Travel post attachment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_travel_post_attachment
      @travel_post_attachment = TravelPostAttachment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def travel_post_attachment_params
      params.require(:travel_post_attachment).permit(:travel_post_id, :s3)
    end
end
