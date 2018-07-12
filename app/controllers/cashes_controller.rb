class CashesController < ApplicationController
  before_action :set_cash, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter(only: [:index, :show]) do
    user = User.find_by_id(current_user.id)
    unless user.is_member? || user.is_admin? || user.is_manager?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end

  before_filter(only: [:new, :create, :edit, :update, :destroy]) do
    user = User.find_by_id(current_user.id)
    unless user.is_manager? || user.is_admin?
      redirect_to cashes_path, :flash => { :error => '권한이 없습니다' }
    end
  end

  LIST_PER_PAGE = 20

  # GET /cashes
  # GET /cashes.json
  def index
    page = params[:page].blank? ? 1 : params[:page]

    @cashes = Cash.all.page(page).per(LIST_PER_PAGE)
    @wallet = Wallet.first
  end

  # GET /cashes/1
  # GET /cashes/1.json
  def show
  end

  # GET /cashes/new
  def new
    @cash = Cash.new
  end

  # GET /cashes/1/edit
  def edit
  end

  # POST /cashes
  # POST /cashes.json
  #
  def create
    if params[:income].present?
      Wallet.first.income_to_wallet(params[:income].to_i)
      @cash = Cash.new(cash_params)
    elsif params[:expenditure].present?
      Wallet.first.expenditure_to_wallet(params[:expenditure].to_i)
      @cash = Cash.new(cash_params)
    end

    respond_to do |format|
      if @cash.save
        format.html { redirect_to cashes_path, notice: 'Cash was successfully created.' }
        format.json { render :show, status: :created, location: @cash }
      else
        format.html { render :new }
        format.json { render json: @cash.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cashes/1
  # PATCH/PUT /cashes/1.json
  def update
    respond_to do |format|
      if @cash.update(cash_params)
        format.html { redirect_to @cash, notice: 'Cash was successfully updated.' }
        format.json { render :show, status: :ok, location: @cash }
      else
        format.html { render :edit }
        format.json { render json: @cash.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cashes/1
  # DELETE /cashes/1.json
  def destroy
    @cash.destroy
    respond_to do |format|
      format.html { redirect_to cashes_url, notice: 'Cash was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cash
      @cash = Cash.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cash_params
      params.permit(:income, :expenditure, :description, :date)
    end
end
