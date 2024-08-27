class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @home = { lat: 52.5200, lon: 13.4050 }
  end

end
