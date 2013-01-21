class Admin::WallpapersController < Admin::BaseController
  def index
    render json: Wallpaper.limit(100).all
  end

  def show
    render json: Wallpaper.find(params[:id])
  end
end