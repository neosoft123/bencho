module ChatHelper
  # include CanHasChat::Util::PageHelper
  
  def render_chatbox_for(chat_id,
                            from,
                            to=nil,
                            update_frequency=2, #ignored if using push connection
                            messages_html_options={},
                            form_html_options={})
    render :partial => "chatbox",
              :locals => {
                :chat_id => chat_id,
                :from => from,
                :to => to,
                :frequency => update_frequency,
                :messages_html_options => messages_html_options,
                :form_html_options => form_html_options
              }
  end
  
  def render_roster_for(chat_id,
                            from,
                            to=nil,
                            update_frequency=2, #ignored if using push connection
                            messages_html_options={},
                            form_html_options={})
    render :partial => "chats/roster",
              :locals => {
                :chat_id => chat_id,
                :from => from,
                :to => to,
                :frequency => update_frequency,
                :messages_html_options => messages_html_options,
                :form_html_options => form_html_options
              }
  end
    
end