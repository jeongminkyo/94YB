class CalendarController < ApplicationController

  def index
    calendars = Calendar.all

    return_calendar = []
    calendars.each do |calendar|
      return_calendar.push(calendar.attributes)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: calendars }
    end
  end
end
