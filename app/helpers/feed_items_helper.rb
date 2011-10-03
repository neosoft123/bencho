module FeedItemsHelper
  
  def content_for_feed_item feed_item, posted_by=nil, content=nil, &block
    if @device && @device.low?
      content_for_feed_item_low feed_item, posted_by, content, &block
    else
      content_for_feed_item_mid feed_item, posted_by, content, &block
    end
  end
  
  def content_for_feed_item_low feed_item, posted_by, content=nil, &block
    feed_item_content = [private_item_icon(feed_item)]
    feed_item_content.unshift(posted_by(posted_by, feed_item.created_at)) unless posted_by.nil?
    feed_item_content << content unless block_given?
    feed_item_content << capture(&block) if block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  


  def content_for_feed_item_mid feed_item, posted_by, content=nil, &block
    feed_item_content = []
    feed_item_content.unshift(posted_by(posted_by, feed_item.created_at)) unless posted_by.nil?
    feed_item_content.unshift(private_item_icon(feed_item)) if (feed_item.respond_to?("private?") && feed_item.private?)
    feed_item_content.unshift(content_tag(:div, link_to(avatar_icon_tag(posted_by, :small, :class => 'profile-pic'), posted_by), :class => 'feed-avatar')) unless posted_by.nil?
    feed_item_content.unshift(
      link_to(image_tag('delete.png'), 
      profile_feed_item_path(@p, feed_item), 
      :method => :delete, 
      :confirm => 'Are you sure?', 
      :class=>'delete')) if me? && !feed_item.is_a?(PublicFeedItem)
    # feed_item_content.unshift("<div style=\"float:right;\">" + avatar_icon_tag(posted_by, {:name => "tiny"}) + "</div>")
    feed_item_content << capture(&block) if block_given?
    feed_item_content << content unless block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  
  def content_for_tweet_feed_item feed_item, tweet, content=nil, &block
    if @device && @device.low?
      content_for_tweet_feed_item_low feed_item, tweet, content, &block
    else
      content_for_tweet_feed_item_mid feed_item, tweet, content, &block
    end
  end
  
  def content_for_tweet_feed_item_low feed_item, tweet, content=nil, &block
    feed_item_content = [
      content_tag(:div,
        link_to(tweet.name, twitter_feed_path(tweet.screen_name)) + " #{time_ago_in_words(tweet.posted_at || Time.now)} ago",
        :class => 'posted-by')
    ]
    feed_item_content.unshift(private_item_icon(feed_item))
    feed_item_content << content unless block_given?
    feed_item_content << capture(&block) if block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  
  def content_for_tweet_feed_item_mid feed_item, tweet, content=nil, &block
    feed_item_content = [
      content_tag(:div,
       link_to(tweet.name, twitter_feed_path(tweet.screen_name)) + " #{time_ago_in_words(tweet.posted_at || Time.now)} ago",
       :class => 'posted-by')
      # link_to(tweet.name, "http://m.twitter.com/"+(tweet.screen_name)) + " #{time_ago_in_words(tweet.posted_at || Time.now)} ago",
      #  :class => 'posted-by')
    ]
    feed_item_content.unshift(private_item_icon(feed_item))
    feed_item_content.unshift(content_tag(:div, link_to(image_tag(tweet.avatar_url, :class => 'profile-pic'), twitter_settings_path), :class => 'feed-avatar'))
    feed_item_content.unshift(
      link_to(image_tag('delete.png'), 
      profile_feed_item_path(@p, feed_item), 
      :method => :delete, 
      :confirm => 'Are you sure?', 
      :class=>'delete')) if me?
    feed_item_content << capture(&block) if block_given?
    feed_item_content << content unless block_given?
    feed_item_content << twitter_status_actions(tweet) if @u.has_twitter_login?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  
  def twitter_status_actions tweet
    content_tag(:div, 
      link_to("Reply", new_profile_profile_status_path(@p) + "?status=" + CGI::escape("@#{tweet.screen_name} ")) + " - " + 
      link_to('Retweet', new_profile_profile_status_path(@p) + "?status=" + CGI::escape("RT @#{tweet.screen_name} #{shortlinkify(tweet.text)}")),
      :class => "feed-item-detail", :style => 'padding-left:0px')
  end
  
  def content_for_facebook_feed_item feed_item, status, content=nil, &block 
    if @device && @device.low?
      content_for_facebook_feed_item_low feed_item, status, content, &block
    else
      content_for_facebook_feed_item_mid feed_item, status, content, &block
    end
  end
  
  def content_for_facebook_feed_item_low feed_item, status, content=nil, &block 
    feed_item_content = [
      content_tag(:div,
        link_to(status.name, facebook_profile_path(status.name)) + " #{time_ago_in_words(status.posted_at || Time.now)} ago",
        :class => 'posted-by')
    ]
    feed_item_content.unshift(private_item_icon(feed_item))
    feed_item_content << content unless block_given?
    feed_item_content << capture(&block) if block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  
  def content_for_facebook_feed_item_mid feed_item, status, content=nil, &block 
    feed_item_content = [
      content_tag(:div,
        link_to(status.name, facebook_profile_path(status.name)) + " #{time_ago_in_words(status.posted_at || Time.now)} ago",
        :class => 'posted-by')
    ]
    feed_item_content.unshift(private_item_icon(feed_item))
    feed_item_content.unshift(content_tag(:div, link_to(image_tag(status.pic_square, :class => 'profile-pic'), facebook_settings_path), :class => 'feed-avatar'))
    feed_item_content.unshift(
      link_to(image_tag('delete.png'), 
      profile_feed_item_path(@p, feed_item), 
      :method => :delete, 
      :confirm => 'Are you sure?', 
      :class=>'delete')) if me?
    feed_item_content << capture(&block) if block_given?
    feed_item_content << content unless block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  
  def content_for_facebook_feed_item_mids feed_item, status, content=nil, &block 
    feed_item_content = [
      content_tag(:div,
        link_to(status.name, facebook_profile_path(status.name)) + " #{time_ago_in_words(status.posted_at || Time.now)} ago",
        :class => 'posted-by')
    ]
    feed_item_content.unshift(private_item_icon(feed_item))
    feed_item_content.unshift(content_tag(:div, link_to(image_tag(status.pic_square, :class => 'profile-pic'), facebook_settings_path), :class => 'feed-avatar'))
    feed_item_content.unshift(
      link_to(image_tag('delete.png'), 
      profile_feed_item_path(@p, feed_item), 
      :method => :delete, 
      :confirm => 'Are you sure?', 
      :class=>'delete')) if me?
    feed_item_content << capture(&block) if block_given?
    feed_item_content << content unless block_given?
    concat content_tag_for(:li, feed_item) { feed_item_content.to_s }
  end
  

  def feed_comments commentable
    content_tag(:div, link_to(pluralize(commentable.comments_count, "Comment"), [commentable.profile, commentable]) + " - " + 
      link_to('Add comment', new_polymorphic_url([commentable.profile, commentable, Comment.new])),
      :class => "feed-item-detail")
  end
  
  def feed_location feed_item
    return unless feed_item.respond_to?(:distance) # depends on whether this was invoked from location sensitive location
    content_tag(:div, pluralize(feed_item.distance, "kilometer") + " away", :class => "feed-item-detail")
  end
    
  def private_item_icon feed_item
    (feed_item.respond_to?("private?") && feed_item.private?) ? image_tag('lock_small.png', :alt => 'private', :title => 'private', :class => 'private-icon') : ''
  end

  def x_feed_link feed_item
    link_to_remote image_tag('delete.png', :class => 'png', :width=>'12', :height=>'12'), :url => profile_feed_item_path(@profile, feed_item), :method => :delete
  end
  
  
  def commentable_text comment, in_html = true
    parent = comment.commentable
    case parent.class.name
    when 'Profile'
      "#{link_to_if in_html, comment.profile.f, comment.profile} wrote a comment on #{link_to_if in_html, parent.f+'\'s', profile_path(parent)} wall"
    when 'Blog'
      "#{link_to_if in_html, comment.profile.f, comment.profile} commented on #{link_to_if in_html, h(parent.title), profile_blog_path(parent.profile, parent)}"
    end
  end
end
