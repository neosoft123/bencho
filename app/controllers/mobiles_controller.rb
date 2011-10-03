class MobilesController < ApplicationController
  
  prepend_before_filter :get_profile
  skip_filter :check_permissions
  before_filter :load_generic_sync_variables, :except => [:provisioning, :sync_help]
  
  def intro
    respond_to do |format|
      format.mobile
    end
  end
  
  def provisioning
    respond_to do |format|
      format.mobile do
        prov = Provisioner.new(@u)
        prov.send_provisioning
      end
    end
  end
  
  def sync_help
  end
  
  # Sync Instructions
  
  def sony_ericsson
    @page_title = 'Sony Ericsson W950i - Symbian'
  end
  
  def nokia_e_series
    @page_title = 'Nokia E-Series - Symbian S60'
  end
  
  def nokia_n_series
    @page_title = 'Nokia N-Series - Symbian S60'
    render :action => :nokia_e_series
  end
  
  def nokia_6630
    @page_title = 'Nokia 6630 - Symbian S60'
  end
  
  def nokia_6230
    @page_title = 'Nokia 6230 or Similar'
  end
  
  def nokia_6300
    @page_title = 'Nokia 6300'
  end
  
  protected
  
  def load_generic_sync_variables
    # Maybe we should have these as class constants in the provisioner?
    @sync_profile_name = '7am'
    @server_address = 'http://ds.7.am/funambol/ds'
    @username = "#{@p.user.login}@#{SITE_NAME}"
    @password = 'your 7.am password'
    @server_version = '1.1'
    @server_id = 'funambol'
    @data_bearer = 'Internet'
    @access_point = 'choose your GPRS, WAP or Wireless settings'
    @port = '8080'
  end
  
  def allow_to
    super :users, :all => true
  end
  
end
