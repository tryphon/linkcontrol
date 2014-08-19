# -*- coding: utf-8 -*-
class NetworksController < ApplicationController
  unloadable

  def index 
    @networks = Network.all
  end

  def show
    @network = Network.find(params[:id])
  end

  def edit
    @network = Network.find(params[:id])
  end

  def update
    @network = Network.find(params[:id])
    if @network.update_attributes params[:network]
      flash[:success] = "La configuration a été modifiée avec succès"
      redirect_to network_path
    else
      flash[:failure] = "La configuration n'a pu être modifiée"
      render :action => "edit"
    end
  end

end
