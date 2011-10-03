module TwitterHelper
  
  def tweetify text
    text.scan(/(@[a-z|0-9|_]+)/i).each do |m|
      text.gsub!(m[0], link_to(m[0], twitter_feed_path(m[0].gsub(/@/, ''))))
    end
    text
  end
  
  def content_for_tweet tweet, content=nil, &block
    tweet_content = [
      content_tag(:div,
        "Posted #{time_ago_in_words(tweet.created_at || Time.now)} ago",
        :class => 'posted-by', :style => 'padding-left:0px')
    ]
    tweet_content << capture(&block) if block_given?
    tweet_content << content unless block_given?
    tweet_content << tweet_actions(tweet) if @u.has_twitter_login?
    concat content_tag(:li) { tweet_content.to_s }
  end
  
  def tweet_actions tweet
    content_tag(:div, 
      link_to("Reply", new_profile_profile_status_path(@p) + "?status=" + CGI::escape("@#{tweet["user"]["screen_name"]} ")) + " - " + 
      link_to('Retweet', new_profile_profile_status_path(@p) + "?status=" + CGI::escape("RT @#{tweet["user"]["screen_name"]} #{shortlinkify(tweet["text"])}")),
      :class => "feed-item-detail", :style => 'padding-left:0px')
  end
  
end