class KontactInformationsController < ApplicationController

  before_filter :get_profile, :find_kontact
  before_filter :find_kontact_information, :only => [:edit, :update, :show]
  
  # GET /kontact_informations/1
  # GET /kontact_informations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.mobile
      format.xml  { render :xml => @kontact_information }
    end
  end

  # GET /kontact_informations/new
  # GET /kontact_informations/new.xml
  def new
    @kontact_information = KontactInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile
      format.xml  { render :xml => @kontact_information }
    end
  end

  # GET /kontact_informations/1/edit
  def edit
  end

  # PUT /kontact_informations/1
  # PUT /kontact_informations/1.xml
  def update
    respond_to do |format|
      if @kontact_information.update_attributes(params[:kontact_information])
        flash[:notice] = 'Contact Information was successfully updated.'
        format.html { redirect_to(profile_kontact_path(@profile, @kontact)) }
        format.mobile { redirect_to(profile_kontact_path(@profile, @kontact)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.mobile { render :action => "edit" }
        format.xml  { render :xml => @kontact_information.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kontact_informations/1
  # DELETE /kontact_informations/1.xml
  def destroy
    @kontact_information = @profile.kontact.kontact_information
    @kontact_information.destroy

    respond_to do |format|
      format.html { redirect_to(kontact_informations_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def find_kontact
    @kontact = @profile.kontacts.find(params[:kontact_id])
  end
  
  def find_kontact_information
    @kontact_information = @kontact.kontact_information
  end
  
  def allow_to
    super :user, :only => [:show]
    super :owner, :all => true
    super :editor, :only => [ :edit , :destroy ]
  end
end