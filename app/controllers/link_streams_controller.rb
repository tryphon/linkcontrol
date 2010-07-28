# -*- coding: utf-8 -*-
class LinkStreamsController < ApplicationController

  def show
    @link_stream = LinkStream.load
  end

  def edit
    @link_stream = LinkStream.load
  end

  def update
    @link_stream = LinkStream.new
    # new and update_attributes are separated to
    # prevent problems with default attributes
    @link_stream.update_attributes params[:link_stream]
    if @link_stream.save
      flash[:success] = "La configuration a été modifiée avec succès"
      redirect_to link_stream_path
    else
      flash[:failure] = "La configuration n'a pu été modifiée"
      render :action => "edit"
    end
  end

end
