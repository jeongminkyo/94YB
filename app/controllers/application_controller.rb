class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :set_picture
  def set_picture
    images = Dir.glob('app/assets/images/*.jpg')
    @picture_num = images[Random.rand(images.size)].split('/').last
  end
end
