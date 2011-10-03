CREATE TABLE `account_entries` (
  `id` int(11) NOT NULL auto_increment,
  `debit` int(11) default NULL,
  `credit` int(11) default NULL,
  `aasm_state` varchar(255) default NULL,
  `reason` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `service_id` int(11) default NULL,
  `wallet_id` int(11) default NULL,
  `response_ref` varchar(255) default NULL,
  `error_code` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;

CREATE TABLE `applications` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audits` (
  `id` int(11) NOT NULL auto_increment,
  `auditable_id` int(11) default NULL,
  `auditable_type` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `user_type` varchar(255) default NULL,
  `username` varchar(255) default NULL,
  `action` varchar(255) default NULL,
  `changes` text,
  `version` int(11) default '0',
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=36083 DEFAULT CHARSET=utf8;

CREATE TABLE `billing_entries` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(255) default NULL,
  `reference` varchar(255) default NULL,
  `reason` varchar(255) default NULL,
  `account_entry_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `body` text,
  `profile_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_blogs_on_profile_id` (`profile_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `business_card_profiles` (
  `id` int(11) NOT NULL auto_increment,
  `business_card_id` int(11) default NULL,
  `profile_id` int(11) default NULL,
  `sync_to_phone` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `business_card_requests` (
  `id` int(11) NOT NULL auto_increment,
  `requester_id` int(11) default NULL,
  `requested_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `chat_invitations` (
  `id` int(11) NOT NULL auto_increment,
  `from_id` int(11) default NULL,
  `to_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `chats` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` int(11) default NULL,
  `topic` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `jabber_password` varchar(255) default NULL,
  `chat_id` varchar(255) default NULL,
  `to` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8;

CREATE TABLE `client_applications` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `support_url` varchar(255) default NULL,
  `callback_url` varchar(255) default NULL,
  `key` varchar(50) default NULL,
  `secret` varchar(50) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_client_applications_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `comment` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `profile_id` int(11) default NULL,
  `commentable_type` varchar(255) NOT NULL default '',
  `commentable_id` int(11) NOT NULL,
  `is_denied` int(11) NOT NULL default '0',
  `is_reviewed` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_comments_on_profile_id` (`profile_id`),
  KEY `index_comments_on_commentable_id_and_commentable_type` (`commentable_id`,`commentable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL auto_increment,
  `priority` int(11) default '0',
  `attempts` int(11) default '0',
  `handler` text,
  `last_error` varchar(1255) default NULL,
  `run_at` datetime default NULL,
  `locked_at` datetime default NULL,
  `failed_at` datetime default NULL,
  `locked_by` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;

CREATE TABLE `device_attributes` (
  `id` int(11) NOT NULL auto_increment,
  `device_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `value` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=321 DEFAULT CHARSET=utf8;

CREATE TABLE `device_content` (
  `id` int(11) NOT NULL auto_increment,
  `vendor` varchar(255) default NULL,
  `model` varchar(255) default NULL,
  `sync_instructions` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `vendor_model_unique` (`vendor`,`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `devices` (
  `id` int(11) NOT NULL auto_increment,
  `user_agent` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `stylesheet_level` varchar(255) default 'low',
  PRIMARY KEY  (`id`),
  KEY `index_devices_on_user_agent` (`user_agent`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `feed_items` (
  `id` int(11) NOT NULL auto_increment,
  `include_comments` tinyint(1) NOT NULL default '0',
  `is_public` tinyint(1) NOT NULL default '0',
  `item_id` int(11) default NULL,
  `item_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `state` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_feed_items_on_item_id_and_item_type` (`item_id`,`item_type`)
) ENGINE=InnoDB AUTO_INCREMENT=162 DEFAULT CHARSET=utf8;

CREATE TABLE `feeds` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` int(11) default NULL,
  `feed_item_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_feeds_on_profile_id_and_feed_item_id` (`profile_id`,`feed_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=utf8;

CREATE TABLE `followships` (
  `id` int(11) NOT NULL auto_increment,
  `follower_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `followed_id` int(11) default NULL,
  `text_message_enabled` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `forum_posts` (
  `id` int(11) NOT NULL auto_increment,
  `body` text,
  `owner_id` int(11) default NULL,
  `topic_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_forum_posts_on_topic_id` (`topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `forum_topics` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `forum_id` int(11) default NULL,
  `owner_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_forum_topics_on_forum_id` (`forum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `forums` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `description` text,
  `position` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `friends` (
  `id` int(11) NOT NULL auto_increment,
  `inviter_id` int(11) default NULL,
  `invited_id` int(11) default NULL,
  `status` int(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `state` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_friends_on_inviter_id_and_invited_id` (`inviter_id`,`invited_id`),
  UNIQUE KEY `index_friends_on_invited_id_and_inviter_id` (`invited_id`,`inviter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `friendships` (
  `id` int(11) NOT NULL auto_increment,
  `friender_id` int(11) default NULL,
  `friendee_id` int(11) default NULL,
  `state` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `online` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `group_invitations` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` int(11) default NULL,
  `inviter_id` int(11) default NULL,
  `invitee_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `group_messages` (
  `id` int(11) NOT NULL auto_increment,
  `group_id` int(11) default NULL,
  `text` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL auto_increment,
  `owner_id` int(11) default NULL,
  `is_public` tinyint(1) default '0',
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `kontacts_count` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `groups_profiles` (
  `profile_id` int(11) default NULL,
  `group_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `help` (
  `id` int(11) NOT NULL auto_increment,
  `controller` varchar(100) default NULL,
  `action` varchar(100) default NULL,
  `content` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `controller_action_unique` (`controller`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `help_users` (
  `help_id` int(11) default NULL,
  `user_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` int(11) default NULL,
  `kontact_id` int(11) default NULL,
  `code` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `jabber_messages` (
  `id` int(11) NOT NULL auto_increment,
  `from_id` int(11) default NULL,
  `to_id` int(11) default NULL,
  `message` varchar(255) default NULL,
  `read` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `owner_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8;

CREATE TABLE `kontact_informations` (
  `id` int(11) NOT NULL auto_increment,
  `display_name` varchar(255) default NULL,
  `formatted_name` varchar(255) default NULL,
  `family_name` varchar(255) default NULL,
  `given_name` varchar(255) default NULL,
  `middle_name` varchar(255) default NULL,
  `honorific_prefix` varchar(255) default NULL,
  `honorific_suffix` varchar(255) default NULL,
  `nickname` varchar(255) default NULL,
  `birthday` varchar(255) default NULL,
  `anniversary` date default NULL,
  `gender` varchar(255) default NULL,
  `note` varchar(255) default NULL,
  `preferred_username` varchar(255) default NULL,
  `utc_offset` datetime default NULL,
  `connected` tinyint(1) default NULL,
  `longitude` decimal(15,10) default NULL,
  `latitude` decimal(15,10) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `owner_id` int(11) default NULL,
  `owner_type` varchar(255) default NULL,
  `icon` varchar(255) default NULL,
  `location` varchar(255) default NULL,
  `about_me` text,
  `digest` varchar(255) default NULL,
  `luid` varchar(255) default NULL,
  `organization` varchar(255) default NULL,
  `type` varchar(255) default 'KontactInformation',
  `uuid` varchar(36) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_kontact_informations_on_id` (`id`),
  KEY `index_kontact_informations_on_created_at` (`created_at`),
  KEY `index_kontact_informations_on_updated_at` (`updated_at`),
  KEY `index_kontact_informations_on_uuid` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=14353 DEFAULT CHARSET=utf8;

CREATE TABLE `kontacts` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `parent_type` varchar(255) default NULL,
  `kontact_information_id` int(11) default NULL,
  `status` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_kontacts_on_parent_type` (`parent_type`),
  KEY `index_kontacts_on_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14120 DEFAULT CHARSET=utf8;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `latitude` decimal(15,10) default NULL,
  `longitude` decimal(15,10) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `profile_id` int(11) default NULL,
  `static_map_url` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `subject` varchar(255) default NULL,
  `body` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `sender_id` int(11) default NULL,
  `receiver_id` int(11) default NULL,
  `read` tinyint(1) NOT NULL default '0',
  `sender_type` varchar(255) default NULL,
  `receiver_type` varchar(255) default NULL,
  `type` varchar(255) default 'Message',
  PRIMARY KEY  (`id`),
  KEY `index_messages_on_sender_id` (`sender_id`),
  KEY `index_messages_on_receiver_id` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `oauth_nonces` (
  `id` int(11) NOT NULL auto_increment,
  `nonce` varchar(255) default NULL,
  `timestamp` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_oauth_nonces_on_nonce_and_timestamp` (`nonce`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `oauth_tokens` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `type` varchar(20) default NULL,
  `client_application_id` int(11) default NULL,
  `token` varchar(50) default NULL,
  `secret` varchar(50) default NULL,
  `authorized_at` datetime default NULL,
  `invalidated_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_oauth_tokens_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `caption` varchar(1000) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `profile_id` int(11) default NULL,
  `image` varchar(255) default NULL,
  `comments_count` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_photos_on_profile_id` (`profile_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;

CREATE TABLE `plural_fields` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(255) default NULL,
  `value` varchar(255) default NULL,
  `field_type` varchar(255) default NULL,
  `primary` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `kontact_information_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `ki` (`kontact_information_id`),
  KEY `type` (`type`),
  KEY `index_plural_fields_on_type` (`type`),
  KEY `index_plural_fields_on_kontact_information_id` (`kontact_information_id`),
  KEY `index_plural_fields_on_field_type` (`field_type`)
) ENGINE=InnoDB AUTO_INCREMENT=12180 DEFAULT CHARSET=utf8;

CREATE TABLE `profile_statuses` (
  `id` int(11) NOT NULL auto_increment,
  `profile_id` int(11) default NULL,
  `text` varchar(140) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `comments_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `location` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `email` varchar(255) default NULL,
  `is_active` tinyint(1) default '0',
  `last_activity_at` datetime default NULL,
  `lat` decimal(15,10) default NULL,
  `lng` decimal(15,10) default NULL,
  `last_checkin` datetime default NULL,
  `display_name` varchar(255) default NULL,
  `family_name` varchar(255) default NULL,
  `given_name` varchar(255) default NULL,
  `middle_name` varchar(255) default NULL,
  `gender` varchar(255) default NULL,
  `birthday` date default NULL,
  `mobile` varchar(255) default NULL,
  `about_me` text,
  `icon` varchar(255) default NULL,
  `kontacts_count` int(11) default NULL,
  `last_user_agent` varchar(255) default NULL,
  `sort_contacts_last_name_first` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  KEY `index_profiles_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `services` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `price_in_cents` int(11) default NULL,
  `credit` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `sts_service_id` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=492 DEFAULT CHARSET=utf8;

CREATE TABLE `settings` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `twitter_login` varchar(255) default NULL,
  `twitter_password` varchar(255) default NULL,
  `send_status_to_facebook` tinyint(1) default '0',
  `upload_photos_to_facebook` tinyint(1) default '0',
  `fireeagle_request_token` varchar(255) default NULL,
  `fireeagle_request_token_secret` varchar(255) default NULL,
  `fireeagle_access_token` varchar(255) default NULL,
  `fireeagle_access_token_secret` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `show_in_public_searches` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) default NULL,
  `taggable_id` int(11) default NULL,
  `tagger_id` int(11) default NULL,
  `tagger_type` varchar(255) default NULL,
  `taggable_type` varchar(255) default NULL,
  `context` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `text_messages` (
  `id` int(11) NOT NULL auto_increment,
  `to` varchar(255) default NULL,
  `message` varchar(255) default NULL,
  `sent` tinyint(1) default NULL,
  `profile_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `href` varchar(255) default NULL,
  `recipient_id` int(11) default NULL,
  `billable` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `is_admin` tinyint(1) default NULL,
  `can_send_messages` tinyint(1) default '1',
  `email_verification` varchar(255) default NULL,
  `email_verified` tinyint(1) unsigned default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `state` varchar(255) default 'passive',
  `deleted_at` datetime default NULL,
  `mobile_activation_code` varchar(255) default NULL,
  `mobile_activated_at` datetime default NULL,
  `last_sync_started` datetime default NULL,
  `last_sync_finished` datetime default NULL,
  `sync_xml` text,
  `fireeagle_request_token` varchar(255) default NULL,
  `fireeagle_request_token_secret` varchar(255) default NULL,
  `fireeagle_access_token` varchar(255) default NULL,
  `fireeagle_access_token_secret` varchar(255) default NULL,
  `twitter_login` varchar(255) default NULL,
  `twitter_password` varchar(255) default NULL,
  `online` tinyint(1) default '0',
  `remind_to_sync_date` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;

CREATE TABLE `wallets` (
  `id` int(11) NOT NULL auto_increment,
  `balance` int(11) default NULL,
  `profile_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20080921170342');

INSERT INTO schema_migrations (version) VALUES ('20080921170855');

INSERT INTO schema_migrations (version) VALUES ('2008100601002');

INSERT INTO schema_migrations (version) VALUES ('200810061001');

INSERT INTO schema_migrations (version) VALUES ('20081018090453');

INSERT INTO schema_migrations (version) VALUES ('20081020052216');

INSERT INTO schema_migrations (version) VALUES ('20081020083647');

INSERT INTO schema_migrations (version) VALUES ('20081020092817');

INSERT INTO schema_migrations (version) VALUES ('20081020093010');

INSERT INTO schema_migrations (version) VALUES ('20081020102423');

INSERT INTO schema_migrations (version) VALUES ('20081022130303');

INSERT INTO schema_migrations (version) VALUES ('20081023130945');

INSERT INTO schema_migrations (version) VALUES ('20081028145256');

INSERT INTO schema_migrations (version) VALUES ('20081030114742');

INSERT INTO schema_migrations (version) VALUES ('20081030124530');

INSERT INTO schema_migrations (version) VALUES ('20081030134953');

INSERT INTO schema_migrations (version) VALUES ('20081105024051');

INSERT INTO schema_migrations (version) VALUES ('20081105033004');

INSERT INTO schema_migrations (version) VALUES ('20081105131951');

INSERT INTO schema_migrations (version) VALUES ('20081106181559');

INSERT INTO schema_migrations (version) VALUES ('20081110073035');

INSERT INTO schema_migrations (version) VALUES ('20081110193605');

INSERT INTO schema_migrations (version) VALUES ('20081111043122');

INSERT INTO schema_migrations (version) VALUES ('20081124064710');

INSERT INTO schema_migrations (version) VALUES ('20081124065033');

INSERT INTO schema_migrations (version) VALUES ('20081125095106');

INSERT INTO schema_migrations (version) VALUES ('20081128090415');

INSERT INTO schema_migrations (version) VALUES ('20081206110601');

INSERT INTO schema_migrations (version) VALUES ('20081212080232');

INSERT INTO schema_migrations (version) VALUES ('20081219221820');

INSERT INTO schema_migrations (version) VALUES ('20081223101136');

INSERT INTO schema_migrations (version) VALUES ('20081223135239');

INSERT INTO schema_migrations (version) VALUES ('20081230134407');

INSERT INTO schema_migrations (version) VALUES ('20081231101142');

INSERT INTO schema_migrations (version) VALUES ('20090102095125');

INSERT INTO schema_migrations (version) VALUES ('20090102104540');

INSERT INTO schema_migrations (version) VALUES ('20090102110510');

INSERT INTO schema_migrations (version) VALUES ('20090102130537');

INSERT INTO schema_migrations (version) VALUES ('20090104143858');

INSERT INTO schema_migrations (version) VALUES ('20090104210906');

INSERT INTO schema_migrations (version) VALUES ('20090104231402');

INSERT INTO schema_migrations (version) VALUES ('20090105093433');

INSERT INTO schema_migrations (version) VALUES ('20090106073910');

INSERT INTO schema_migrations (version) VALUES ('20090107100851');

INSERT INTO schema_migrations (version) VALUES ('20090107135403');

INSERT INTO schema_migrations (version) VALUES ('20090107150059');

INSERT INTO schema_migrations (version) VALUES ('20090107150748');

INSERT INTO schema_migrations (version) VALUES ('20090108111015');

INSERT INTO schema_migrations (version) VALUES ('20090108143324');

INSERT INTO schema_migrations (version) VALUES ('20090108184452');

INSERT INTO schema_migrations (version) VALUES ('20090109174427');

INSERT INTO schema_migrations (version) VALUES ('20090112003355');

INSERT INTO schema_migrations (version) VALUES ('20090113184141');

INSERT INTO schema_migrations (version) VALUES ('20090114070346');

INSERT INTO schema_migrations (version) VALUES ('20090114141239');

INSERT INTO schema_migrations (version) VALUES ('20090121125536');

INSERT INTO schema_migrations (version) VALUES ('20090121135901');

INSERT INTO schema_migrations (version) VALUES ('20090122115358');

INSERT INTO schema_migrations (version) VALUES ('20090122150144');

INSERT INTO schema_migrations (version) VALUES ('20090122151111');

INSERT INTO schema_migrations (version) VALUES ('20090123093553');

INSERT INTO schema_migrations (version) VALUES ('20090123103220');

INSERT INTO schema_migrations (version) VALUES ('20090123120831');

INSERT INTO schema_migrations (version) VALUES ('20090126102952');

INSERT INTO schema_migrations (version) VALUES ('20090127105143');

INSERT INTO schema_migrations (version) VALUES ('20090127113913');

INSERT INTO schema_migrations (version) VALUES ('20090127133547');

INSERT INTO schema_migrations (version) VALUES ('20090128112749');

INSERT INTO schema_migrations (version) VALUES ('20090129053702');

INSERT INTO schema_migrations (version) VALUES ('20090129120548');

INSERT INTO schema_migrations (version) VALUES ('20090129183921');

INSERT INTO schema_migrations (version) VALUES ('20090129185825');

INSERT INTO schema_migrations (version) VALUES ('20090130083727');

INSERT INTO schema_migrations (version) VALUES ('20090130092843');

INSERT INTO schema_migrations (version) VALUES ('20090201235141');

INSERT INTO schema_migrations (version) VALUES ('20090204081236');

INSERT INTO schema_migrations (version) VALUES ('20090204100329');

INSERT INTO schema_migrations (version) VALUES ('20090204100603');

INSERT INTO schema_migrations (version) VALUES ('20090204135601');

INSERT INTO schema_migrations (version) VALUES ('20090205065740');

INSERT INTO schema_migrations (version) VALUES ('20090205120833');

INSERT INTO schema_migrations (version) VALUES ('20090205124455');

INSERT INTO schema_migrations (version) VALUES ('20090205125034');

INSERT INTO schema_migrations (version) VALUES ('20090205132320');

INSERT INTO schema_migrations (version) VALUES ('20090205134027');

INSERT INTO schema_migrations (version) VALUES ('20090205145912');

INSERT INTO schema_migrations (version) VALUES ('20090205152928');

INSERT INTO schema_migrations (version) VALUES ('20090205173908');

INSERT INTO schema_migrations (version) VALUES ('20090205194453');

INSERT INTO schema_migrations (version) VALUES ('20090206074418');

INSERT INTO schema_migrations (version) VALUES ('20090206091846');

INSERT INTO schema_migrations (version) VALUES ('20090209140709');

INSERT INTO schema_migrations (version) VALUES ('20090210074104');

INSERT INTO schema_migrations (version) VALUES ('20090210074745');

INSERT INTO schema_migrations (version) VALUES ('20090210092117');

INSERT INTO schema_migrations (version) VALUES ('20090210142206');

INSERT INTO schema_migrations (version) VALUES ('20090210145521');

INSERT INTO schema_migrations (version) VALUES ('20090212100329');

INSERT INTO schema_migrations (version) VALUES ('20090212123645');

INSERT INTO schema_migrations (version) VALUES ('20090212183854');

INSERT INTO schema_migrations (version) VALUES ('20090213074721');

INSERT INTO schema_migrations (version) VALUES ('20090215135407');

INSERT INTO schema_migrations (version) VALUES ('20090217111258');