class WallpapersController < ApplicationController

  def index
    @page = params[:page] || 1
    @wallpapers = Wallpaper.paginate(page: @page, per_page: 20, include: [:colors, :tags])

    @body = render_to_string(partial: 'wallpapers/wallpaper', layout: false, collection: @wallpapers)

    respond_to do |format|
      format.html
      format.json {
        sleep(5)
        render json: { body: @body }
      }
    end
  end
end