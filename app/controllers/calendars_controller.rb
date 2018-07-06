class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter(only: [:index, :show, :edit, :update, :destroy]) do
    user = User.find_by_id(current_user.id)
    unless user.is_member? || user.is_admin? || user.is_manager?
      redirect_to root_path, :flash => { :error => '권한이 없습니다' }
    end
  end

  def index
    calendars = Calendar.all

    return_calendar = []
    calendars.each do |calendar|
      return_calendar.push(calendar.attributes)
      return_calendar.last['edit_url'] = '/calendars/' + calendar.id.to_s + '/edit'
      return_calendar.last['update_url'] = '/calendars/' + calendar.id.to_s
      return_calendar.last['color'] = User.find(calendar.user_id).color
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: return_calendar }
    end
  end

  def new
    @calendar = Calendar.new
  end

  def edit

  end

  def create
    @calendar = Calendar.new(title: params['calendar']['title'], start: params['calendar']['start'], end: params['calendar']['end'], user_id: current_user.id)
    respond_to do |format|
      if @calendar.save
        format.html { redirect_to calendars_path, notice: '일정이 등록되었습니다.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @calendar.update(start: params['calendar']['start'], end: params['calendar']['end'])
        format.html { redirect_to calendars_path, notice: '일정이 변경되었습니다.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @calendar.destroy
    respond_to do |format|
      format.html { redirect_to calendars_path }
    end
  end

  private
  def set_calendar
    @calendar = Calendar.find(params[:id])
  end
end
