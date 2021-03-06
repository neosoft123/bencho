# Change globals to match the proper value for your site

DELETE_CONFIRM = "Are you sure you want to delete?\nThis can not be undone."
SEARCH_LIMIT = 25
SITE_NAME = '7.am'
SITE = RAILS_ENV == 'production' ? '7.am' : 'localhost:3000'

MAILER_TO_ADDRESS = 'info@#{SITE}'
MAILER_FROM_ADDRESS = 'The 7.am Team <info@7.am>'
REGISTRATION_RECIPIENTS = %W(support@agilisto.com) #send an email to this list everytime someone signs up


YOUTUBE_BASE_URL = "http://gdata.youtube.com/feeds/api/videos/"