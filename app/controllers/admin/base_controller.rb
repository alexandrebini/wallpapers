class Admin::BaseController < ApplicationController
  http_basic_authenticate_with name: 'wall-e', password: 'wall1712' unless Rails.env == 'development'
end