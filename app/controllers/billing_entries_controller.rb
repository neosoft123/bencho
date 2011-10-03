class BillingEntriesController < ApplicationController
  # GET /billing_entries
  # GET /billing_entries.xml
  def index
    @billing_entries = BillingEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @billing_entries }
    end
  end

  # GET /billing_entries/1
  # GET /billing_entries/1.xml
  def show
    @billing_entry = BillingEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @billing_entry }
    end
  end

  # GET /billing_entries/new
  # GET /billing_entries/new.xml
  def new
    @billing_entry = BillingEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @billing_entry }
    end
  end

  # GET /billing_entries/1/edit
  def edit
    @billing_entry = BillingEntry.find(params[:id])
  end

  # POST /billing_entries
  # POST /billing_entries.xml
  def create
    @billing_entry = BillingEntry.new(params[:billing_entry])

    respond_to do |format|
      if @billing_entry.save
        flash[:notice] = 'BillingEntry was successfully created.'
        format.html { redirect_to(@billing_entry) }
        format.xml  { render :xml => @billing_entry, :status => :created, :location => @billing_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @billing_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /billing_entries/1
  # PUT /billing_entries/1.xml
  def update
    @billing_entry = BillingEntry.find(params[:id])

    respond_to do |format|
      if @billing_entry.update_attributes(params[:billing_entry])
        flash[:notice] = 'BillingEntry was successfully updated.'
        format.html { redirect_to(@billing_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @billing_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /billing_entries/1
  # DELETE /billing_entries/1.xml
  def destroy
    @billing_entry = BillingEntry.find(params[:id])
    @billing_entry.destroy

    respond_to do |format|
      format.html { redirect_to(billing_entries_url) }
      format.xml  { head :ok }
    end
  end
  
  protected 
  def allow_to
    super :admin, :all => true
    super :owner, :all => true
  end
end
