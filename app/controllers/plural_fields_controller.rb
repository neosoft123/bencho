class PluralFieldsController < ApplicationController
  
  before_filter :find_kontact, :find_kontact_information
  
  # GET /plural_fields
  # GET /plural_fields.xml
  def index
    @phone_numbers = @kontact_information.phone_numbers
    @emails = @kontact_information.emails

    respond_to do |format|
      format.html # index.html.erb
      format.mobile
      format.xml  { render :xml => @plural_fields }
    end
  end

  # GET /plural_fields/1
  # GET /plural_fields/1.xml
  def show
    @plural_fields = PluralFields.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.mobile
      format.xml  { render :xml => @plural_fields }
    end
  end

  # GET /plural_fields/new
  # GET /plural_fields/new.xml
  def new
    @plural_fields = PluralFields.new

    respond_to do |format|
      format.html # new.html.erb
      format.mobile
      format.xml  { render :xml => @plural_fields }
    end
  end

  # GET /plural_fields/1/edit
  def edit
    @plural_fields = PluralFields.find(params[:id])
  end

  # POST /plural_fields
  # POST /plural_fields.xml
  def create
    @plural_fields = PluralFields.new(params[:plural_fields])

    respond_to do |format|
      if @plural_fields.save
        flash[:notice] = 'PluralFields was successfully created.'
        format.html { redirect_to(@plural_fields) }
        format.xml  { render :xml => @plural_fields, :status => :created, :location => @plural_fields }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plural_fields.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plural_fields/1
  # PUT /plural_fields/1.xml
  def update
    @plural_fields = PluralFields.find(params[:id])

    respond_to do |format|
      if @plural_fields.update_attributes(params[:plural_fields])
        flash[:notice] = 'PluralFields was successfully updated.'
        format.html { redirect_to(@plural_fields) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plural_fields.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plural_fields/1
  # DELETE /plural_fields/1.xml
  def destroy
    @plural_fields = PluralFields.find(params[:id])
    @plural_fields.destroy

    respond_to do |format|
      format.html { redirect_to(plural_fields_url) }
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
    super :owner, :all => true
  end

end
