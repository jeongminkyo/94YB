source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.7'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.6.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# admin
gem 'rails_admin'

# bootstrap
gem 'bootstrap-sass', '~> 3.4.1'
gem 'simple_form'
gem 'bootstrap-datepicker-rails'

# social login
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-naver'

#권한설정
gem 'rolify'
gem 'authority'

# 환경변수
gem 'figaro'

# CORS
gem 'rack-cors'

# Calendar
gem 'simple_calendar', '~> 2.0'
gem 'fullcalendar-rails'
gem 'momentjs-rails'
gem 'bootstrap-daterangepicker-rails'

#file upload
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
gem 'mini_magick'
gem 'fog-aws'

# 페이징
gem 'kaminari'

#ruby version issue
gem 'i18n', '~>1.5'

# oj
gem 'oj', '~> 3.7', '>= 3.7.12'

# JWT
gem 'jwt', '2.2.1'
gem 'hashie', '4.1.0'

gem 'google-id-token'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Rspec
group :test do
  # Rspec
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'simplecov'
  gem 'simplecov-json'
  gem 'simplecov-rcov'
  gem 'faker', '1.9.1'
  gem 'webmock'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rails-controller-testing'
end

gem 'capistrano', '~> 3.7'
gem 'capistrano-rails', '~> 1.1.0'
gem 'capistrano-rbenv'
gem 'capistrano-bundler'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-nginx'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]