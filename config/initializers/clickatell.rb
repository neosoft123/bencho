module Clickatell
  class API
    def send_syncml_ota_message(recipient, data, udh, opts={})
      response = execute_command('sendmsg', 'http', 
        { :to => recipient, :data => data, :udh => udh }.merge(opts)
      )
      puts response.inspect
      parse_response(response)['ID']
    end
  end
end