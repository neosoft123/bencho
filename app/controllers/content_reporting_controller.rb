class ContentReportingController < ApplicationController
  
  def create
    HoptoadNotifier.notify(
      :error_class => "Inappropriate Content", 
      :error_message => @message,
      :request => { :params => get_params_from_calling_page }
    )
    redirect_back_or_default('/')
  end
  
  private
  
  def get_params_from_calling_page
    hop_toad_params = params.clone
    hop_toad_params.delete :commit
    @message = hop_toad_params.delete :message
    
    hop_toad_params[:controller] = hop_toad_params[:c]
    hop_toad_params.delete :c
    hop_toad_params[:action] = hop_toad_params[:a]
    hop_toad_params.delete :a
    
    return hop_toad_params
  end
  
  def allow_to
    super :user, :all => true
  end
  
end
