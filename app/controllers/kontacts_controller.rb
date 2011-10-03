class KontactsController < ApplicationController
 
  before_filter :find_parent
  before_filter :find_kontact , :only => [ :show, :edit , :destroy ]   
  before_filter :build_kontact, :only => [:index, :new, :upload_icon]
  
  skip_filter :store_location, :only => [:create, :update, :destroy, :basic_search_proc, :sync, :upload_icon]
  
  # in_place_edit_for :phone_number , :value
  # in_place_edit_for :email , :value
  
  def sort_last_first
    @profile.sort_contacts_last_first
    redirect_back_or_default(profile_kontacts_path(@profile))
  end
  
  def sort_first_last
    @profile.sort_contacts_first_last
    redirect_back_or_default(profile_kontacts_path(@profile))
  end
  
  def index
    respond_to do |format|
      format.html do
        #@kontacts = @parent.kontacts.sorted.paginate(:page => params[:page], :per_page => 15)
        @kontacts = @parent.kontacts.sorted
        render :layout => 'new_application'
      end
      format.xml  { render :xml => @parent.kontacts.sorted }
      format.mobile do
        get_contacts
      end
    end
  end
  
  def might_be_friends
    
    sql = <<-EOV
      select * from profiles 
      where mobile in
      (
        select value from plural_fields 
        where kontact_information_id in
        (
          select id from kontact_informations 
          where type = "KontactInformation"
          and id in
          (
            select kontact_information_id from kontacts
            where parent_id = :pid
            and parent_type = "Profile"
            and status = "contact"
            and parent_id not in 
            (
              select friendee_id from friendships
              where friender_id = :pid
            )
          )
        )
      )
    EOV
    
    @profiles = Profile.paginate_by_sql([sql, { :pid => @p.id }], :page => params[:page], :per_page => 10)
    
  end
  
  def by_letter
    respond_to do |format|
      format.mobile do
        @kontacts = if @parent.sort_contacts_last_name_first?
          @parent.kontacts.sorted_by_last_name.by_letter(params[:letter], @profile).paginate(:page => params[:page], :per_page => 10)
        else
          @parent.kontacts.sorted_by_first_name.by_letter(params[:letter], @profile).paginate(:page => params[:page], :per_page => 10)
        end
        #@kontacts = @parent.kontacts.sorted.by_letter(params[:letter]).paginate(:page => params[:page], :per_page => 10)
        @search_results = true
        render :action => :index
      end
    end
  end
  
  def add_shared_contacts
    if params[:add]
      ids = params[:add].map{|id|id.to_i}
      KontactInformation.transaction do
        KontactInformation.find(ids).each do |ki|
          unless @p.kontact_informations.include?(ki)
            @p.kontacts.new(
              :kontact_information => ki,
              :status => Kontact::CONTACT
            ).save
          end
        end
      end
      flash[:notice] = "<h3>Contacts added</h3>The selected contacts are now added to your contact list"
    else
      flash[:error] = "<h3>No contacts added</h3>You did not select any contacts to be added"
    end
    redirect_to profile_shared_contacts_path(@p)
  end
  
  def shared_contacts
    respond_to do |format|
      format.mobile do
        @kontacts = @p.shared_contacts.paginate :page => params[:page], :per_page => 10
        @added_kontacts = @kontacts.map{|k|(@p.kontact_informations.include?(k.ki)) ? k.ki : nil}
      end
    end
  end

  # GET /kontacts/1
  # GET /kontacts/1.xml
  def show
    @kontact = @parent.kontacts.find(params[:id])
    
    respond_to do |format|
      format.html do
        if session[:new_kontact_flag]
          session[:new_kontact_flag] = nil
          ( redirect_to edit_profile_kontact_path({ :id => @parent , :kontact_id => @kontact }) )
        else
          render
        end
      end
      format.xml  { render :xml => @kontact }
      format.mobile {}
    end
  end

  # GET /kontacts/new
  # GET /kontacts/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kontact }
    end
  end

  # GET /kontacts/1/edit
  def edit
    @kontact_information = @kontact.kontact_information
    @phone_number = @kontact_information.inplace_phone_number
    @phone_numbers = @kontact_information.phone_numbers.secondary
    @emails = @kontact_information.emails.secondary
    @email = @kontact_information.inplace_email
  end

  # POST /kontacts
  # POST /kontacts.xml
  def create

      kontact_information_attributes = {:owner => @parent}.merge(params[:kontact].delete(:kontact_information))
      kontact_attributes = {:status => Kontact::CONTACT}.merge(params.delete(:kontact))
      
      @kontact = @parent.kontacts.build(kontact_attributes)
      @kontact_information = @kontact.build_kontact_information(kontact_information_attributes)
      respond_to do |format|
        if @kontact_information.valid? and @kontact.save
          flash[:notice] = 'Kontact was successfully created.'
          format.js do
            @new_kontact = @kontact
            @kontacts = @parent.kontacts.sorted
            build_kontact
          end
          session[:new_kontact_flag] = params[:new_kontact_flag] if params[:new_kontact_flag]
          format.html { redirect_to([@parent, @kontact]) }
          format.xml  { render :xml => @kontact_information, :status => :created, :location => @kontact }
        else
          # Getting a weird error with flash[:error] = @kontact_information.errors
          flash[:error] = @kontact_information.errors.full_messages.uniq.join("; ")
          format.js { 
            render :update do |page|
              flash_notice(page)
              page.replace_html 'new_kontact', :partial => 'new_kontact' 
            end
          }
          format.html { render :action => "new" }
          format.xml  { render :xml => @kontact_information.errors, :status => :unprocessable_entity }
        end
      end
  end
  
   # POST /kontacts/sync
   # POST /kontacts/sync.xml
   def sync

     kontact_information_attributes = {:owner => @parent}.merge(params[:kontact].delete(:kontact_information))
     kontact_attributes = {:status => Kontact::CONTACT}.merge(params.delete(:kontact))

     @kontact = @parent.kontacts.build(kontact_attributes)
     @kontact_information = @kontact.build_kontact_information(kontact_information_attributes)
     puts @kontact_information.inspect
     digest = @kontact_information.calc_digest()
     
     respond_to do |format|
       format.mobile do
         if @profile.kontact_informations.find_all_by_digest(digest).length() > 0
           render :xml => @kontact_information.errors, :status => :unprocessable_entity
         else
           @kontact_information.save(false)
           @kontact.kontact_information = @kontact_information
           @kontact.save(false)
           render :xml => @kontact_information.errors, :status => :created, :location => profile_kontact_url(@parent, @kontact)
         end
       end
     end
     
   end
  

  # PUT /kontacts/1
  # PUT /kontacts/1.xml
  def update
    @kontact = @parent.kontacts.find(params[:id])
    @kontact_information = @kontact.kontact_information
    kontact_information_attributes = params[:kontact].delete(:kontact_information)
    kontact_information_attributes[:existing_phone_number_attributes] ||= {}
    kontact_information_attributes[:existing_email_attributes] ||= {}
    
    kontact_information_attributes.inspect
    kontact_attributes = params.delete(:kontact)
      
    respond_to do |format|
      if (@kontact.kontact_information.update_attributes(kontact_information_attributes) & 
          @kontact.update_attributes(kontact_attributes))
        flash[:notice] = 'Kontact was successfully updated.'
        format.js
        format.html { redirect_to([@parent, @kontact]) }
        format.xml  { head :ok }
      else
        flash[:error] = @kontact.errors
        format.js { 
          render :update do |page|
            flash_notice(page)
            page.replace_html 'kontact_more_detail', :partial => 'form' 
          end
        }
        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kontact.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def upload_icon
    # REVIEW: Can upload for anybody...
    @kontact = Kontact.find(params[:kontact_id])    
    @kontact_information = @kontact.kontact_information
    @kontact_information.attributes = params[:kontact_information]
    @kontact_information.save(false)
    redirect_to :action => :edit , :id => @parent , :kontact_id => @kontact
  end

  # DELETE /kontacts/1
  # DELETE /kontacts/1.xml
  def destroy
    @kontact.destroy

    respond_to do |format|
      format.html { redirect_to(kontacts_url(:id => @parent)) }
      format.xml  { head :ok }
    end
  end
  
  def basic_search
    respond_to do |format|
      format.mobile
    end
  end
  
  def basic_search_proc
    respond_to do |format|
      format.mobile do
        @q = params[:q]
        if @q.blank?
          flash.now[:error] = "Please enter something to search for.."
          get_contacts
        else
          @kontacts = @profile.kontacts.find(:all, :include => :kontact_information,
            :conditions => ['kontact_informations.given_name like :q or kontact_informations.family_name like :q or kontact_informations.display_name like :q', 
              { :q => "%#{params[:q]}%" }]).paginate(:page => params[:page], :per_page => 10)
          @search_results = true
        end
        render :action => :index
      end
    end
  end
  
  protected
  
  def get_contacts
    if @parent.is_a?(Profile)
      @kontacts = if @parent.sort_contacts_last_name_first?
        @parent.kontacts.sorted_by_last_name.paginate(:page => params[:page], :per_page => 10)
      else
        @parent.kontacts.sorted_by_first_name.paginate(:page => params[:page], :per_page => 10)
      end
    else
      @kontacts = @parent.kontacts.sorted_by_last_name.paginate(:page => params[:page], :per_page => 10)
    end
  end
  
  def allow_to
    super :owner, :all => true
    super :user, :only => [:show]
  end
  
  def find_kontact
    @kontact = params[:kontact_id] ? Kontact.find(params[:kontact_id]) : @parent.kontacts.find(params[:id])
  end
  
  def find_parent
    # TODO: Other owners
    @parent = @profile
    @parent = @group = Group.find(params[:group_id]) if params[:group_id]
  end
    
  def build_kontact
    @kontact = @parent.kontacts.build
    @kontact.build_kontact_information
  end
  
end
