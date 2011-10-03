class PhoneNumbersController < ApplicationController

  before_filter :get_profile, :find_kontact, :find_kontact_information
  before_filter :find_phone_number, :only => [:show, :edit, :update, :destroy]

  # GET /phone_numbers
  # GET /phone_numbers.xml
  def index
    @phone_numbers = @kontact_information.phone_numbers.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phone_numbers }
    end
  end

  # GET /phone_numbers/1
  # GET /phone_numbers/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /phone_numbers/new
  # GET /phone_numbers/new.xml
  def new
    @phone_number = @kontact_information.phone_numbers.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /phone_numbers/1/edit
  def edit
  end

  # POST /phone_numbers
  # POST /phone_numbers.xml
  def create
    @phone_number = @kontact_information.phone_numbers.build(params[:phone_number])
    respond_to do |format|
      if @phone_number.save
        flash[:notice] = 'Phone number was successfully created.'
        format.html { redirect_to(@phone_number) }
        format.mobile {redirect_to profile_kontact_kontact_information_plural_fields_path(@profile, @kontact)}
        format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phone_numbers/1
  # PUT /phone_numbers/1.xml
  def update

    respond_to do |format|
      if @phone_number.update_attributes(params[:phone_number])
        flash[:notice] = 'Phone number was successfully updated.'
        format.html { redirect_to(@phone_number) }
        format.mobile { redirect_to profile_kontact_kontact_information_plural_fields_path(@profile, @kontact)}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phone_numbers/1
  # DELETE /phone_numbers/1.xml
  def destroy
    @phone_number.destroy

    respond_to do |format|
      format.html { redirect_to(phone_numbers_url) }
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
  
  def find_phone_number
    @phone_number = @kontact_information.phone_numbers.find(params[:id])
  end
  
  def allow_to
    super :owner, :all => true
  end

end
