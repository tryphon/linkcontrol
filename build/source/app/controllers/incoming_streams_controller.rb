# -*- coding: utf-8 -*-
class IncomingStreamsController < ApplicationController

  def show
    @incoming_stream = IncomingStream.load
  end

  def edit
    @incoming_stream = IncomingStream.load
  end

  def update
    @incoming_stream = IncomingStream.new
    # new and update_attributes are separated to
    # prevent problems with default attributes
    @incoming_stream.update_attributes params[:incoming_stream]
    if @incoming_stream.save
      flash[:success] = t("incoming_streams.flash.update.success")
      redirect_to incoming_stream_path
    else
      flash[:failure] = t("incoming_streams.flash.update.failure")
      render :action => "edit"
    end
  end

end
