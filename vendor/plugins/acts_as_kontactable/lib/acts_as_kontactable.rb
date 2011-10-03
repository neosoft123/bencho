module Agilisto  
  module Acts #nodoc:
    module Kontactable #nodoc:

      def self.included(base) # :nodoc:  
        base.extend ClassMethods
      end
  
      module ClassMethods

        def pass_kontact_info(mappings={})
          raise ArgumentError unless mappings.is_a?(Hash)
          class_eval <<-EOV
            def kmappings
              #{mappings.inspect}
            end
          EOV
        end
        
        def acts_as_kontactable(options = {})
          
          has_many :kontacts, :as => :parent, :include => {:kontact_information => [:emails, :urls, :phone_numbers]} do
            def own
              first :conditions => ['status = "own"']
            end
          end
          has_many :kontact_informations, :through => :kontacts, :uniq => true
          has_one  :kontact_information, :as => :owner

          after_save :update_kontact_information
          
          extend Agilisto::Acts::Kontactable::SingletonMethods
          include Agilisto::Acts::Kontactable::InstanceMethods
        end
      end
  
      module InstanceMethods

        def add_kontact(relationship, *args)
          if args.last.type_of? Hash
            kontact_information = KontactInformation.create(args)
          end
          if args.last.type_of? KontactInformation
            kontact_information = args
          end
          self.kontacts << Kontact.create(:status => relationship, :kontact_information => kontact_information)
        end
        
        def class_name
          self.class.name.underscore
        end

        def update_kontact_information
          
          self.kontact_information = KontactInformation.new(:owner => self) unless self.kontact_information 
          
          # set profile email address as primary KI email
          self.kontact_information.primary_email = self.email unless self.email.blank?
          
          # set mapped profile fields on KI
          kmappings.each do |origin, destination|
            self.kontact_information.send("#{destination}=", self.send(origin))
          end
          
          self.kontact_information.save(false)

        end

      end
      
      # Class singleton methods to mix into ActiveRecord.
      module SingletonMethods
      end  
    end
  end
end

ActiveRecord::Base.class_eval do
  include Agilisto::Acts::Kontactable
end