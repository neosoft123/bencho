require File.dirname(__FILE__) + '/../test_helper'
require 'factory_girl'
require '../factories'

class KontactTest < ActiveSupport::TestCase

  context 'A Kontact instance created by the sync interface should skip ki validation on create' do
    puts File.dirname(__FILE__)
    @jim = Factory(:jim)
    ki = KontactInformation.new(:owner => @jim.profile, :should_validate => false)

    invalid_phone_number = PhoneNumber.new(:value => '11')
    ki.phone_numbers << invalid_phone_number
    
    k = @jim.profile.kontacts.create(
      :status => Kontact::CONTACT, 
      :parent =>  @jim.profile,
      :kontact_information => ki
    )

    # Leaving the logic as is for the minute. 
    
    @jim.delete
  end
  
  def teardown
    puts "DTTTTT"
  end
  
end