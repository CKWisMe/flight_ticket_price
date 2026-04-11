class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t("search_requests.flash.not_found") }
      format.json { render json: { error: "not_found" }, status: :not_found }
    end
  end
end
