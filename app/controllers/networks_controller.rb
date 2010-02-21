# -*- coding: utf-8 -*-
class NetworksController < ApplicationController

  def edit
    @network = Network.load
  end

  def update
    @network = Network.new(params[:network])
    if @network.save
      flash[:notice] = "La configuration a été modifiée avec succès"
      redirect_to edit_network_path
    else
      flash[:failure] = "La configuration n'a pu été modifiée"
      render :action => "edit"
    end
  end

end
