class Admin::WallpapersController < Admin::BaseController
  def index
    render json: Wallpaper.limit(100).all
  end

  def show
    render json: Wallpaper.find(params[:id])
  end

  def create
    wallpaper = Wallpaper.new(params[:wallpaper])
    if wallpaper.save
      render json: wallpaper
    else
      render json: { errors: wallpaper.errors }, status: 422
    end
  end
end