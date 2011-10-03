require File.dirname(__FILE__) + '/../test_helper'

class MsisdnTest < Test::Unit::TestCase

  def test_international_dial_code
    msisdn = Msisdn.new('+27825559629') 
    assert_equal msisdn.country_code, '27'
  end

end