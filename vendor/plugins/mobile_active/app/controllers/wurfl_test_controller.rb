class WurflTestController < ApplicationController
  def index
    user_agent = request.user_agent
    puts user_agent
    dev = WurflDevice.find_by_user_agent(user_agent)

    @ua = user_agent
    if dev
      @brand = dev.brand
      @model = dev.model
    else
      @brand = 'unknown'
      @model = 'unknown'
    end
  end
end
