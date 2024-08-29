class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @home = { lat: current_user.home_lat, lon: current_user.home_lon }
    else
      @home = { lat: 52.5200, lon: 13.4050, hide: true }
    end

    collection = DataImporter.new.call
    @unformatted_data = collection[:unformatted_data]
    @formatted_data = collection[:formatted_data]
    @radiuses = collection[:radiuses]

  end
end
