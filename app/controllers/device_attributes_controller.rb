class DeviceAttributesController < ApplicationController

  before_filter :find_device
  before_filter :find_device_attribute, :only => [:show, :edit, :update, :destroy]
  
  # GET /device_attributes
  # GET /device_attributes.xml
  def index
    @device_attributes = @device.device_attributes.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @device_attributes }
    end
  end

  # GET /device_attributes/1
  # GET /device_attributes/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device_attribute }
    end
  end

  # GET /device_attributes/new
  # GET /device_attributes/new.xml
  def new
    @device_attribute = @device.device_attributes.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device_attribute }
    end
  end

  # GET /device_attributes/1/edit
  def edit

  end

  # POST /device_attributes
  # POST /device_attributes.xml
  def create
    @device_attribute = @device.device_attributes.build(params[:device_attribute])

    respond_to do |format|
      if @device_attribute.save
        flash[:notice] = 'DeviceAttribute was successfully created.'
        format.html { redirect_to(device_device_attributes_path(@device, @device_attribute)) }
        format.xml  { render :xml => @device_attribute, :status => :created, :location => @device_attribute }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /device_attributes/1
  # PUT /device_attributes/1.xml
  def update

    respond_to do |format|
      if @device_attribute.update_attributes(params[:device_attribute])
        flash[:notice] = 'DeviceAttribute was successfully updated.'
        format.html { redirect_to(device_device_attribute_path(@device, @device_attribute)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device_attribute.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /device_attributes/1
  # DELETE /device_attributes/1.xml
  def destroy
    @device_attribute.destroy

    respond_to do |format|
      format.html { redirect_to(device_attributes_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def find_device
    @device = Device.find(params[:device_id])
  end
  
  def find_device_attribute
    @device_attribute = @device.device_attributes.find(params[:id])
  end
  
  def allow_to
    super :all, :all => true
  end
  
end
