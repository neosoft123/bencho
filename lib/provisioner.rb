class Provisioner
  
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def build_xml(password=nil)
    
    password ||= user.password
    
    xml = <<-EOV
      <?xml version="1.0"?>
      <wap-provisioningdoc version="1.0">
      	<characteristic type="BOOTSTRAP">
      		<parm name="NAME" value="7am Sync"/>
      	</characteristic>
      	<characteristic type="APPLICATION">
      		<parm name="APPID" value="w5"/>
      		<parm name="NAME" value="7am"/>
      		<parm name="TO-NAPID" value="INTERNET"/>
      		<characteristic type="APPADDR">
      			<parm name="ADDR" value="http://ds.7.am/funambol/ds"/>
      			<characteristic type="PORT">
      				<parm name="PORTNBR" value="8080"/>
      			</characteristic>
      		</characteristic>
      		<characteristic type="APPAUTH">
      			<parm name="AAUTHNAME" value="$username"/>
      			<parm name="AAUTHSECRET" value="$password"/>
      		</characteristic>
      		<characteristic type="RESOURCE">
      			<parm name="URI" value="card"/>
      			<parm name="NAME" value="Contacts DB"/>
      			<parm name="AACCEPT" value="text/x-vcard"/>
      		</characteristic>
      	</characteristic>
      </wap-provisioningdoc>
    EOV
    
    xml.gsub!(/\$username/, "#{user.login}@#{SITE_NAME}")
    xml.gsub!(/\$password/, password)
    user.update_attribute(:sync_xml, xml)
  end

  def send_provisioning(mobile=nil)
    #mobile = @user.profile.kontact_information.phone_numbers.primary.mobile.first
    mobile ||= @user.profile.mobile # yeah baby
    #raise "No mobile number" unless mobile and mobile.value
    unless mobile# and mobile.value
      RAILS_DEFAULT_LOGGER.debug "No mobile number, cannot provision"
      return
    end
    
    xml_file = "#{user.login}-#{user.id}.xml"
    xml_file = File.join(RAILS_ROOT, 'tmp', xml_file)
    wbxml_file = xml_file.gsub(/\.xml/, '.wbxml')

    # force delete output files if they exist
    puts system("rm -f #{xml_file}") if File.exists?(xml_file)
    puts system("rm -f #{wbxml_file}") if File.exists?(wbxml_file)
    
    # write xml file
    File.open(xml_file, 'w+') do |file|
      file.write @user.sync_xml.gsub(/\s*</,'<')
    end

    # create wbxml file
    puts system("xml2wbxml -o #{wbxml_file} #{xml_file}")
    
    # open the WBXML file
    file = File.open(wbxml_file, 'r')
    wbxml = file.read
    file.close

    # convert WBXML to hex
    data = bin_to_hex(wbxml)
    puts "WBXML: #{data}"
    data = build_wsp_header(wbxml, '1234') << data

    puts "DATA: (Length=#{data.length/2} bytes) #{data}"
    
    # send_via_clickatell mobile, data
    send_via_smartcall mobile, data
    
  end
  
  protected
  
  def send_via_smartcall mobile, data
    require 'pp'
    
    # smartcall requires smaller payloads than clickatel, hex cannot be 
    # longer than 254, including the WDP/UDH headers (which are 24 long)
    parts = []
    while data.length > 0
      if data.length > 230
        parts << data.slice!(0, 230)
      else
        parts << data.slice!(0, data.length)
      end
    end
    
    require File.join(RAILS_ROOT, 'lib', 'soap', 'sts' , 'SmsWSClient')
    api = SmsWSClient.new
    0.upto(parts.length-1) do |i|
      pp "Sending part: #{i+1}, #{parts[i].length/2} bytes"
      pp api.send_binary_sms(mobile, build_wdp(parts.length, i+1), parts[i])
    end
  end
  
  def send_via_clickatell mobile, data
    
    # split the data into 128 byte payloads
    parts = []
    while data.length > 0
      if data.length > 256
        parts << data.slice!(0, 256)
      else
        parts << data.slice!(0, data.length)
      end
    end
    
    # api = Clickatell::API.authenticate('3129027', 'craigp', 'starl1ng')
    api = Clickatell::API.authenticate('3149763', 'armanddp', '@g!l!st0')
    0.upto(parts.length-1) do |i|
      puts "Sending part: #{i+1}"
      puts(api.send_syncml_ota_message(mobile, parts[i], build_wdp(parts.length, i+1))).inspect
    end
  end
  
  def to_bin(s)
    s.unpack('c*').collect{|x|~x}.pack('c*')
  end

  def hex_to_bin(hex)
    #to_bin(hex.gsub(/\s/, '').to_a.pack('H*'))
    hex.gsub(/\s/,'').to_a.pack('H*')
  end

  def bin_to_hex(bin)
    bin.unpack('H*').join
  end

  def build_wdp(total_sms, sms_number) # NOTE FOR THE CONFUSED: WDP == UDH

    hex = []
    hex << '0B'                   # Length of WDP header (11 bytes)
    hex << '0504'                 # Header info
    hex << '0B84'                 # Source port (2948)
    #hex << 'C34C'                 # 49996 (SyncML settings port)
    hex << '23F0'                 # Port from Nokia forums, who knows
    #hex << '0B84'                 # Source port (2948)
    hex << '00'                   # Header info
    hex << '03'                   # Multi-SMS header length (SAR)
    hex << 'A8'                   # Datagram reference (from Nokia forums, no idea wtf this means)
    #hex << '27'                   # Datagram reference
    hex << "0#{total_sms}"        # Total number of SMS messages
    hex << "0#{sms_number}"       # Current message part

    puts "WDP: (Length=#{hex.join.length/2} bytes) #{hex.join}"

    hex.join

  end

  def build_wsp_header(content, key)

    # Built as per OMA Provisioning Content Spec

    hex = []
    hex << '01'                   # TID - [WSP] Ch. 8.2.1   
    hex << '06'                   # PDU Type (PUSH) - [WSP] Ch. 8.2.1 + App. A  
    hex << '2F1F2D'               # Headers Length - [WSP] Ch. 8.2.4.1  
    hex << 'B6'                   # Content-Type - application/vnd.wap.connectivity-wbxml  
    hex << '9181'                 # SEC - USERPIN
    hex << '92'                   # MAC
    hex << mac_val(content, key)  # MAC-value (should be 40 bytes long according to OMA spec)
    hex << '00'

    puts "WSP Header: (Length=#{hex.join.length/2} bytes) #{hex.join}"

    hex.join

  end

  def mac_val(msg, key)
    hmac = HMAC::SHA1.new(key)
    hmac.update(msg)
    s = hmac.to_s
    puts "HMAC: (Length=#{s.length} bytes) #{s}"
    hex_s = ''
    0.upto(s.length-1) do |i|
      hex_s << s[i].to_s(16)
    end
    puts "HMAC (Hex Length=#{hex_s.length/2} bytes): #{hex_s}"
    hex_s
  end
  
end