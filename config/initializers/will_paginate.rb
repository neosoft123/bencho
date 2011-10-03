module WillPaginate
  module ViewHelpers
    @@pagination_options = {
      :class          => 'pagination',
      :previous_label => '&laquo;',
      :next_label     => '&raquo;',
      :inner_window   => 2, # links around the current page
      :outer_window   => 1, # links around beginning and end
      :separator      => ' ', # single space is friendly to spiders and non-graphic browsers
      :param_name     => :page,
      :params         => nil,
      :renderer       => 'WillPaginate::LinkRenderer',
      :page_links     => true,
      :container      => true
    }
  end
end