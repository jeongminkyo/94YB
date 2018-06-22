class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:edit, :update, :destroy]


  def index
    calendars = Calendar.all

    return_calendar = []
    calendars.each do |calendar|
      return_calendar.push(calendar.attributes)
      return_calendar.last['edit_url'] = '/calendars/' + calendar.id.to_s + '/edit'
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
    @calendar = Calendar.new(calendar_params)
    @calendar.save
  end

  def update
    @calendar.update(calendar_params)
  end

  def destroy
    @calendar.destroy
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:id])
  end

  def calendar_params
    params.require(:calendars).permit(:title, :start, :end)
  end
end
