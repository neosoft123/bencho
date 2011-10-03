module ActionController
  
  class Base
    
    protected
    
      def redirect_to(options = {}, response_status = {}) #:doc:
        raise ActionControllerError.new("Cannot redirect to nil!") if options.nil?
        
        logger.debug("NOTE: Using redirect_to monkey patched to status 303")

        if options.is_a?(Hash) && options[:status]
          status = options.delete(:status)
        elsif response_status[:status]
          status = response_status[:status]
        else
          status = 303
        end

        response.redirected_to = options

        case options
          # The scheme name consist of a letter followed by any combination of
          # letters, digits, and the plus ("+"), period ("."), or hyphen ("-")
          # characters; and is terminated by a colon (":").
          when %r{^\w[\w\d+.-]*:.*}
            redirect_to_full_url(options, status)
          when String
            redirect_to_full_url(request.protocol + request.host_with_port + options, status)
          when :back
            if referer = request.headers["Referer"]
              redirect_to(referer, :status=>status)
            else
              raise RedirectBackError
            end
          else
            redirect_to_full_url(url_for(options), status)
        end
      end
    
  end
  
end

class << ActiveRecord::Base
  def dom_id
    "#{self.class.name.underscore}_#{self.id}"
  end
end

module ActionView
  module Helpers
    
    module UrlHelper
      
      def link_to(name, options = {}, html_options = nil)
        url = case options
          when String
            options
          when :back
            @controller.request.env["HTTP_REFERER"] || 'javascript:history.back()'
          else
            self.url_for(options)
          end

        if html_options
          html_options = html_options.stringify_keys
          
          if mobile?
            html_options.delete('confirm') unless supports_javascript?
          end
                    
          href = html_options['href']
          convert_options_to_javascript!(html_options, url)
          tag_options = tag_options(html_options)
        else
          tag_options = nil
        end

        href_attr = "href=\"#{url}\"" unless href
        "<a #{href_attr}#{tag_options}>#{name || url}</a>"
      end
      
    end
    
    module FormTagHelper
      
      def submit_tag(value = "Save changes", options = {})
        options.stringify_keys!

        if mobile?
          options.delete('disable_with') unless supports_javascript?
        end
          
        if disable_with = options.delete("disable_with")
          disable_with = "this.value='#{disable_with}'"
          disable_with << ";#{options.delete('onclick')}" if options['onclick']
          
          options["onclick"]  = "if (window.hiddenCommit) { window.hiddenCommit.setAttribute('value', this.value); }"
          options["onclick"] << "else { hiddenCommit = this.cloneNode(false);hiddenCommit.setAttribute('type', 'hidden');this.form.appendChild(hiddenCommit); }"
          options["onclick"] << "this.setAttribute('originalValue', this.value);this.disabled = true;#{disable_with};"
          options["onclick"] << "result = (this.form.onsubmit ? (this.form.onsubmit() ? this.form.submit() : false) : this.form.submit());"
          options["onclick"] << "if (result == false) { this.value = this.getAttribute('originalValue');this.disabled = false; }return result;"
        end

        if confirm = options.delete("confirm")
          options["onclick"] ||= ''
          options["onclick"] << "return #{confirm_javascript_function(confirm)};"
        end

        tag :input, { "type" => "submit", "name" => "commit", "value" => value }.update(options.stringify_keys)
      end
    end
    
  end
end


