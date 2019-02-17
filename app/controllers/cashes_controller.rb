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

    @cashes = Cash.all.order('date desc').page(page).per(LIST_PER_PAGE)
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
    if params[:status].to_i == Cash::Status::INCOME
      Wallet.first.income_to_wallet(params[:money].to_i)
      params[:current_money] = Wallet.first.current_money
    elsif params[:status].to_i == Cash::Status::EXPENDITURE
      Wallet.first.expenditure_to_wallet(params[:money].to_i)
      params[:user_id] = User.find_by_email('admin@email.com').id
      params[:current_money] = Wallet.first.current_money
    end

    @cash = Cash.new(cash_params)

    respond_to do |format|
      if @cash.save
        format.html { redirect_to cashes_path, notice: 'Cash was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cash
      @cash = Cash.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cash_params
      params.permit(:money, :description, :date, :status, :user_id, :current_money)
    end
end
