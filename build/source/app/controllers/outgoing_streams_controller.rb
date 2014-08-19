# -*- coding: utf-8 -*-
class OutgoingStreamsController < ApplicationController

  def show
    @outgoing_stream = OutgoingStream.load
  end

  def edit
    @outgoing_stream = OutgoingStream.load
  end

  def update
    @outgoing_stream = OutgoingStream.new
    # new and update_attributes are separated to
    # prevent problems with default attributes
    @outgoing_stream.update_attributes params[:outgoing_stream]
    if @outgoing_stream.save
      flash[:success] = t("outgoing_streams.flash.update.success")
      redirect_to outgoing_stream_path
    else
      flash[:failure] = t("outgoing_streams.flash.update.failure")
      render :action => "edit"
    end
  end

end
