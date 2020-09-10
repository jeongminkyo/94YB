class ErrorController < ApplicationController

  URI_NOT_FOUND = 'URI_NOT_FOUND'

  def not_found
    std_exception_handler(URI_NOT_FOUND)
  end
end