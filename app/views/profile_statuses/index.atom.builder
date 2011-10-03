atom_feed(:root_url => profile_profile_statuses_url(@profile)) do |feed|
  feed.title("Status feed for #{@profile.formatted_name}")
  feed.updated(@statuses.first.created_at)

  @statuses.each do |status|
    feed.entry(status, :url => profile_profile_status_url(@profile, status)) do |entry|
      entry.title('Profile status update')
      entry.content(render(:partial => 'profile_statuses/atom_entry', :locals => { :status => status }), :type => 'html')
      entry.author do |author|
        author.name(status.profile.formatted_name)
      end
    end
  end
end
