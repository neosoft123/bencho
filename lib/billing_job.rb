require File.join(RAILS_ROOT, 'lib', 'soap', 'obs' , 'obs_client')

class BillingJob < Struct.new(:account_entry_id)
  def perform
    puts "Processing Billing Job #{account_entry_id}"
    account_entry = AccountEntry.find(account_entry_id)
    
    # TODO this is a temporary solution
    raise "Transaction already processed" if account_entry.processed?
    
    # = Response
    # 
    # HTTP/1.1 200 OK
    # Date: Sun, 10 May 2009 15:25:31 GMT
    # Server: Microsoft-IIS/6.0
    # X-Powered-By: ASP.NET
    # X-AspNet-Version: 2.0.50727
    # Cache-Control: private, max-age=0
    # Content-Type: text/xml; charset=utf-8
    # Content-Length: 457
    # 
    # <?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><processRequest2Response xmlns="http://tempuri.org/"><processRequest2Result>InvalidNetwork</processRequest2Result><responseref>60860130</responseref><responsedescription /><errorcode /></processRequest2Response></soap:Body></soap:Envelope>
    # 
    # RESULT 0
    # rake aborted!
    # Event 'processed' cannot transition from 'processed'

    result = ObsClient.process_request(
        :service => account_entry.service.sts_service_id,
        :msisdn => account_entry.wallet.profile.mobile,
        :description => account_entry.service.description, 
        :tx_id => account_entry.id, 
        :sub_type => 'A', 
        :sub_date => DateTime.now)

    puts "RESULT #{result.inspect}"
    account_entry.success
    
    # NOTE removed as per Gary - still think this is a bad idea (http://support.7.am/discussions/problems/75-sb-confirmation-sms)
    # send_success_notification(account_entry)
    add_billing_log_entry(account_entry, result)
    
    rescue BillingError => b
      add_billing_log_entry(account_entry, b.response)
      account_entry.reason = b.response.reason
      account_entry.error_code = b.response.code
      account_entry.denied!
      send_failed_notification(account_entry)
    rescue StandardError => e
      puts e.inspect
      puts e.backtrace
      raise e
  end    
  
  private
  def add_billing_log_entry(account_entry, response)
    be = account_entry.billing_entries.build(:code => response.code, :reference => response.reference, :reason => response.reason)
    be.save!
  end
  
  def send_success_notification(account_entry)
    builder = SmsBuilder.new(:partial => "sms/billing_processed")
    wallet = account_entry.wallet

    message = builder.render_to_string(binding)
    send_billing_notification(account_entry, message)
  end
  
  def send_failed_notification(account_entry)
    builder = SmsBuilder.new(:partial => "sms/billing_failed")
    wallet = account_entry.wallet
    message = builder.render_to_string(binding)
    send_billing_notification(account_entry, message)
  end
  
  def send_billing_notification(account_entry, message)
    profile = account_entry.wallet.profile
    text_message = profile.text_messages.create(
        :recipient => profile,
        :to => profile.mobile, :message => message, :billable => false)
     Delayed::Job.enqueue(SmsJob.new(text_message.id))
  end
end