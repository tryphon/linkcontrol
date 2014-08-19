class ReleasesController < ApplicationController
  unloadable
  respond_to :html, :xml, :json

  def show
    @release = resource
    respond_with @release
  end

  def index
    @current = Box::Release.current
    
    @latest = Box::Release.latest
    @latest = nil unless @latest.newer?(@current)

    Rails.logger.debug "current: #{@current.inspect}"
    Rails.logger.debug "latest: #{@latest.inspect}"
  end

  def download
    resource.start_download
    resource.change_status :download_pending

    redirect_to releases_path
  end

  def install
    resource.install
    redirect_to releases_path
  end

  def description
    render :partial => "releases/release", :object => resource
  end

  protected

  def resource
    @release ||= 
      case params[:id]
      when "current"
        Box::Release.current
      when "latest"
        Box::Release.latest
      else
        raise ActiveRecord::RecordNotFound.new(params[:id])
      end
  end

end
