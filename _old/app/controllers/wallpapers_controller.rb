class WallpapersController < ApplicationController

  def index
    @page = params[:page] || 1
    @wallpapers = Wallpaper.recent.paginate(page: @page, per_page: 8,
      include: [:colors, :tags])

    @body = render_to_string(partial: 'wallpapers/wallpaper', layout: false,
      collection: @wallpapers, locals: { highlight: highlight(@wallpapers) })

    respond_to do |format|
      format.html
      format.json {
        sleep(1)
        render json: { body: @body }
      }
    end
  end

  private
  def highlight(wallpapers)
    wallpapers.sort_by{ |r| r.views }.last
  end

end