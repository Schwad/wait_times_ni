class StaticPagesController < ApplicationController
  def index
    @hospitals = Hospital.all
  end
end
