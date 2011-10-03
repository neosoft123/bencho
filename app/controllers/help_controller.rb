class HelpController < ApplicationController
  
  def show
    session[:show_help] = true
    redirect_back_or_default '/'
  end
  
  def hide
    session[:show_help] = false
    redirect_back_or_default '/'
  end
  
  private
  
  def allow_to
    super :user, :all => true
  end
  
end
