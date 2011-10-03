require File.join(RAILS_ROOT, 'lib', 'soap', 'obs' , 'obs_client')

class DatingSubscriptionJob < Struct.new(:profile_id)
  
  def perform
    profile = Profile.find(profile_id)
    raise "Profile not found: #{profile_id}" unless profile
    
    service = Service.find_by_title("DatingSubscription")
    raise "Service not found" unless service
    
    puts "Processing dating subscription job for #{profile.f}"
    result = ObsClient.process_request(
      :service => service.sts_service_id,
      :msisdn => profile.mobile.gsub(/\+/, ""),
      :description => service.description, 
      :tx_id => profile.dating_profile.id, 
      :sub_type => 'A', 
      :sub_date => DateTime.now
    )
    
    puts "RESULT #{result.inspect}"
    
    subs = add_subscription_billing_entry(profile, service, result)
    subs.processed!
    profile.dating_profile.update_attribute(:last_billed, DateTime.now)
    send_success_notification(profile)
    
  rescue BillingError => b
    subs = add_subscription_billing_entry(profile, service, result)
    subs.denied!
    send_failed_notification(profile)
  rescue StandardError => e
    puts e.inspect
    puts e.backtrace
    raise e
  end
  
  private

    def add_subscription_billing_entry(profile, service, response)
      subs = profile.subscription_billing_entries.new(
        :code => response.code,
        :reference => response.reference,
        :reason => response.reason,
        :service => service
      )
      subs.save!
      subs
    end
  
    def send_success_notification(profile)
      builder = SmsBuilder.new(:partial => "sms/subs_billing_processed")
      message = builder.render_to_string(binding)
      send_billing_notification(profile, message)
    end
  
    def send_failed_notification(profile)
      builder = SmsBuilder.new(:partial => "sms/subs_billing_failed")
      message = builder.render_to_string(binding)
      send_billing_notification(profile, message)
    end
  
    def send_billing_notification(profile, message)
      text_message = profile.text_messages.create(
          :recipient => profile,
          :to => profile.mobile, :message => message, :billable => false)
       Delayed::Job.enqueue(SmsJob.new(text_message.id))
    end
  
end