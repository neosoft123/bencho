require 'rubygems'
require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'static_gmaps')
include StaticGmaps

STATIC_GOOGLE_MAP_DEFAULT_PARAMETERS_TEST_IMAGE_PATH = File.join File.dirname(__FILE__), 'test_image.gif'

describe StaticGmaps do
  describe Map, 'initialize with no attributes' do
    before(:each) do @map = StaticGmaps::Map.new end
    
    it 'should set center to default'   do @map.center.should   == StaticGmaps::Map::DEFAULT_CENTER end
    it 'should set zoom to default'     do @map.zoom.should     == StaticGmaps::Map::DEFAULT_ZOOM end
    it 'should set size to default'     do @map.size.should     == StaticGmaps::Map::DEFAULT_SIZE end
    it 'should set map_type to default' do @map.map_type.should == StaticGmaps::Map::DEFAULT_MAP_TYPE end
    it 'should set key to default'      do @map.key.should      == StaticGmaps::Map::DEFAULT_KEY end
    it 'should set its markers default' do @map.markers.should  == StaticGmaps::Map::DEFAULT_MARKERS end
  end
  
  describe Map, 'initialize with all attributes' do
    before(:each) do
      @marker = StaticGmaps::Marker.new :latitude => 0, :longitude => 0
      @map = StaticGmaps::Map.new :center   => [ 40.714728, -73.998672 ],
                                  :zoom     => 12,
                                  :size     => [ 500, 400 ],
                                  :map_type => :roadmap,
                                  :key      => 'ABQIAAAAzr2EBOXUKnm_jVnk0OJI7xSosDVG8KKPE1-m51RBrvYughuyMxQ-i1QfUnH94QxWIa6N4U6MouMmBA',
                                  :markers  => [ @marker ]
    end
    
    it 'should set center'   do @map.center.should   == [ 40.714728, -73.998672 ] end
    it 'should set zoom'     do @map.zoom.should     == 12 end
    it 'should set size'     do @map.size.should     == [ 500, 400 ] end
    it 'should set map_type' do @map.map_type.should == :roadmap end
    it 'should set key'      do @map.key.should      == 'ABQIAAAAzr2EBOXUKnm_jVnk0OJI7xSosDVG8KKPE1-m51RBrvYughuyMxQ-i1QfUnH94QxWIa6N4U6MouMmBA' end
    it 'should set markers'  do @map.markers.should  == [ @marker ] end
  end
  
  describe Map, 'with default attributes' do
    before(:each) do @map = StaticGmaps::Map.new end
    
    it 'should have a url'    do @map.url.should      == 'http://maps.google.com/staticmap?center=0,0&key=ABQIAAAAzr2EBOXUKnm_jVnk0OJI7xSosDVG8KKPE1-m51RBrvYughuyMxQ-i1QfUnH94QxWIa6N4U6MouMmBA&map_type=roadmap&size=500x400&zoom=1' end
    it 'should have a width'  do @map.width.should    == 500 end
    it 'should have a height' do @map.height.should   == 400 end
    #it 'should respond to to_blob with an image' do @map.to_blob.should  == File.read(STATIC_GOOGLE_MAP_DEFAULT_PARAMETERS_TEST_IMAGE_PATH) end
  end
  
  describe Map, 'with default attributes and markers' do
    before(:each) do
      @marker_1 = StaticGmaps::Marker.new :latitude => 10, :longitude => 20, :color => 'green', :alpha_character => 'A'
      @marker_2 = StaticGmaps::Marker.new :latitude => 15, :longitude => 25, :color => 'blue', :alpha_character => 'B'
      @map = StaticGmaps::Map.new :markers  => [ @marker_1, @marker_2 ]
    end
    
    it 'should have a markers_url_fragment'              do @map.markers_url_fragment.should == '10,20,greena|15,25,blueb' end
    it 'should include the markers_url_fragment its url' do @map.url.should include(@map.markers_url_fragment) end
  end
    
  describe Marker, 'initialize with no attributes' do
    before(:each) do @marker = StaticGmaps::Marker.new end
  
    it 'should set latitude to default'        do @marker.latitude.should        == StaticGmaps::Marker::DEFAULT_LATITUDE end
    it 'should set longitude to default'       do @marker.longitude.should       == StaticGmaps::Marker::DEFAULT_LONGITUDE end
    it 'should set color to default'           do @marker.color.should           == StaticGmaps::Marker::DEFAULT_COLOR end
    it 'should set alpha_character to default' do @marker.alpha_character.should == StaticGmaps::Marker::DEFAULT_ALPHA_CHARACTER end
  end
  
  describe Marker, 'initialize with all attributes' do
    before(:each) do
      @marker = StaticGmaps::Marker.new :latitude => 12,
                                        :longitude => 34,
                                        :color => 'red',
                                        :alpha_character => 'z'
    end
    
    it 'should set latitude'        do @marker.latitude.should        == 12 end
    it 'should set longitude'       do @marker.longitude.should       == 34 end
    it 'should set color'           do @marker.color.should           == :red end
    it 'should set alpha_character' do @marker.alpha_character.should == :z end
  end
end