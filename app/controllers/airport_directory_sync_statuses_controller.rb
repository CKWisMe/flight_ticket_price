class AirportDirectorySyncStatusesController < ApplicationController
  def show
    @sync_run = AirportDirectorySyncRunRepository.new.latest

    if @sync_run.nil?
      render json: { error: "尚無同步紀錄" }, status: :not_found
      return
    end

    render :show
  end
end
