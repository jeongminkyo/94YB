class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:edit, :update, :destroy]

  def index
    calendars = Calendar.all

    return_calendar = []
    calendars.each do |calendar|
      return_calendar.push(calendar.attributes)
      return_calendar.last['edit_url'] = '/calendars/' + calendar.id.to_s + '/edit'
      return_calendar.last['update_url'] = '/calendars/' + calendar.id.to_s
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
    @calendar = Calendar.new(title: params['calendar']['title'], start: params['calendar']['start'], end: params['calendar']['end'], user_id: 1)
    respond_to do |format|
      if @calendar.save
        format.html { redirect_to calendars_path, notice: 'Event was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @calendar.update(start: params['calendar']['start'], end: params['calendar']['end'])
        format.html { redirect_to calendars_path, notice: 'Event was successfully updated.' }
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
