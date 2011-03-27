CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `master_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_attachments_on_type_and_master_id` (`type`,`master_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `attentions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_attentions_on_user_id_and_target_id_and_target_type` (`user_id`,`target_id`,`target_type`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state_id` int(11) NOT NULL,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cities_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=503 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `colleagues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `colleague_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `colleague_pass_id` int(11) DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT '未定',
  `is_judge` tinyint(1) DEFAULT '0',
  `my_pass_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commentable_id` int(11) NOT NULL,
  `up` int(11) DEFAULT '0',
  `down` int(11) DEFAULT '0',
  `content` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `commentable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `companies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `description` text COLLATE utf8_unicode_ci,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `create_user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `salary_value` int(11) DEFAULT '0',
  `condition_value` int(11) DEFAULT '0',
  `company_judges_count` int(11) DEFAULT '0',
  `fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_edit_user_id` int(11) DEFAULT NULL,
  `industry_root_id` int(11) DEFAULT NULL,
  `industry_second_id` int(11) DEFAULT NULL,
  `industry_third_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  `company_type_id` int(11) DEFAULT NULL,
  `company_size_id` int(11) DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `topics_count` int(11) NOT NULL DEFAULT '0',
  `jobs_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_companies_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `company_judges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `salary_value` int(11) DEFAULT '0',
  `condition_value` int(11) DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci,
  `anonymous` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_company_judges_on_company_id_and_user_id` (`company_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `company_sizes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_sizes_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `company_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_types_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `company_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `description` text COLLATE utf8_unicode_ci,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_company_versions_on_company_id` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `educations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `begin_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `degree` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `major` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `school_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_educations_on_resume_id_and_school_id` (`school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `friends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `friend_id` int(11) DEFAULT NULL,
  `friend_type` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_friends_on_user_id_and_friend_id` (`user_id`,`friend_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `group_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `group_type_id` int(11) NOT NULL,
  `join_type` varchar(16) COLLATE utf8_unicode_ci NOT NULL,
  `create_user_id` int(11) NOT NULL,
  `members_count` int(11) DEFAULT '0',
  `topics_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recommends_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_groups_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_industries_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `job_applicants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `applicant_id` int(11) NOT NULL,
  `recommend_id` int(11) DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted_by_published` tinyint(1) DEFAULT '0',
  `is_deleted_by_applicant` tinyint(1) DEFAULT '0',
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `job_titles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `job_description` text COLLATE utf8_unicode_ci NOT NULL,
  `skill_description` text COLLATE utf8_unicode_ci,
  `state_id` int(11) NOT NULL,
  `city_id` int(11) NOT NULL,
  `job_title_id` int(11) DEFAULT NULL,
  `end_at` datetime NOT NULL,
  `create_user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `view_count` int(11) DEFAULT '0',
  `applicants_count` int(11) DEFAULT '0',
  `comments_count` int(11) DEFAULT '0',
  `skill_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `judges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pass_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `judger_id` int(11) DEFAULT NULL,
  `creditability_value` int(11) DEFAULT '0',
  `ability_value` int(11) DEFAULT '0',
  `eq_value` int(11) DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci,
  `anonymous` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `colleague_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_judges_on_pass_id_and_user_id_and_judger_id` (`pass_id`,`user_id`,`judger_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `log_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logable_id` int(11) DEFAULT NULL,
  `log_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `operation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `changes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(18) COLLATE utf8_unicode_ci DEFAULT 'Normal',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_members_on_group_id_and_user_id` (`group_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `msgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) NOT NULL,
  `sendee_id` int(11) NOT NULL,
  `title` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `content` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_check` tinyint(1) DEFAULT '0',
  `sender_stop` tinyint(1) DEFAULT '0',
  `sendee_stop` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `my_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `need_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `poster_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type_id` int(11) NOT NULL DEFAULT '0',
  `skill_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `view_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `title` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `create_user_id` int(11) NOT NULL,
  `last_edit_user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `up` int(11) DEFAULT '0',
  `down` int(11) DEFAULT '0',
  `comments_count` int(11) DEFAULT '0',
  `recommends_count` int(11) DEFAULT '0',
  `view_count` int(11) DEFAULT '0',
  `last_edit_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `passes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `resume_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `department` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `begin_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `work_description` text COLLATE utf8_unicode_ci,
  `is_current` tinyint(1) DEFAULT '0',
  `creditability_value` int(11) DEFAULT '0',
  `ability_value` int(11) DEFAULT '0',
  `eq_value` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `judges_count` int(11) DEFAULT '0',
  `job_title_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_passes_on_company_id_and_resume_id_and_user_id` (`company_id`,`resume_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `recommends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `memo` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `recommendable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `recommendable_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_recommendable_user` (`user_id`,`recommendable_type`,`recommendable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `requisitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `applicant_id` int(11) DEFAULT NULL,
  `respondent_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `applicant_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_requisition_applicant` (`applicant_id`,`respondent_id`,`applicant_type`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `resumes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type_name` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `sex` tinyint(1) DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `telephone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone4` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `blog_website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `personal_website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website4` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `self_description` text COLLATE utf8_unicode_ci,
  `goal` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `interests` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `qq` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `msn` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `industry` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_schools_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `skill_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `skill_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `skill_taggings_index` (`skill_id`,`taggable_id`,`taggable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_skills_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `specialities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `skill_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_specialities_on_resume_id_and_skill_id` (`skill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_states_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `taggable_id` int(11) NOT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_tags_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_taggings_on_tag_id_and_taggable_id_and_taggable_type` (`tag_id`,`taggable_id`,`taggable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `owner_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `author_id` int(11) NOT NULL,
  `title` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `up` int(11) DEFAULT '0',
  `down` int(11) DEFAULT '0',
  `comments_count` int(11) DEFAULT '0',
  `view_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `top_level` tinyint(1) DEFAULT '0',
  `can_comment` tinyint(1) DEFAULT '1',
  `last_comment_user_id` int(11) DEFAULT NULL,
  `last_comment_datetime` datetime DEFAULT NULL,
  `recommends_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_topics_on_owner_type_and_owner_id` (`owner_type`,`owner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `all_resume_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `img_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `edu_summary_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `pass_summary_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `sex_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `birthday_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `blog_site_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `web_site_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `msn_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `qq_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `address_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `mobile_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `phone_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `self_description_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `pass_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `work_item_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `judge_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `edu_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `speciality_visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT '公开',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `apply_friend_auth` varchar(255) COLLATE utf8_unicode_ci DEFAULT '允许',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_settings_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tagging_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nick_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '马甲',
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `is_active` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `state` varchar(12) COLLATE utf8_unicode_ci DEFAULT 'freedom',
  `salt` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_votes_on_owner_id_and_owner_type_and_user_id` (`owner_id`,`owner_type`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `work_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `begin_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `work_content` text COLLATE utf8_unicode_ci,
  `work_description` text COLLATE utf8_unicode_ci,
  `pass_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20090519023938');

INSERT INTO schema_migrations (version) VALUES ('20090526082924');

INSERT INTO schema_migrations (version) VALUES ('20090531011947');

INSERT INTO schema_migrations (version) VALUES ('20090601063407');

INSERT INTO schema_migrations (version) VALUES ('20090604022911');

INSERT INTO schema_migrations (version) VALUES ('20090604123402');

INSERT INTO schema_migrations (version) VALUES ('20090605031221');

INSERT INTO schema_migrations (version) VALUES ('20090605064331');

INSERT INTO schema_migrations (version) VALUES ('20090629023311');

INSERT INTO schema_migrations (version) VALUES ('20090706073056');

INSERT INTO schema_migrations (version) VALUES ('20090708024839');

INSERT INTO schema_migrations (version) VALUES ('20090713084047');

INSERT INTO schema_migrations (version) VALUES ('20090723060441');

INSERT INTO schema_migrations (version) VALUES ('20090728070328');

INSERT INTO schema_migrations (version) VALUES ('20090730075028');

INSERT INTO schema_migrations (version) VALUES ('20090731072731');

INSERT INTO schema_migrations (version) VALUES ('20090807082638');

INSERT INTO schema_migrations (version) VALUES ('20090819084025');

INSERT INTO schema_migrations (version) VALUES ('20090903051800');

INSERT INTO schema_migrations (version) VALUES ('20090904022946');

INSERT INTO schema_migrations (version) VALUES ('20090909072200');

INSERT INTO schema_migrations (version) VALUES ('20090910063849');

INSERT INTO schema_migrations (version) VALUES ('20090917071408');

INSERT INTO schema_migrations (version) VALUES ('20090921082126');

INSERT INTO schema_migrations (version) VALUES ('20090921083349');

INSERT INTO schema_migrations (version) VALUES ('20090921084916');

INSERT INTO schema_migrations (version) VALUES ('20090921085156');

INSERT INTO schema_migrations (version) VALUES ('20090925084158');

INSERT INTO schema_migrations (version) VALUES ('20090928081553');

INSERT INTO schema_migrations (version) VALUES ('20090929052804');

INSERT INTO schema_migrations (version) VALUES ('20091004083434');

INSERT INTO schema_migrations (version) VALUES ('20091010084720');

INSERT INTO schema_migrations (version) VALUES ('20091012023655');

INSERT INTO schema_migrations (version) VALUES ('20091015054807');

INSERT INTO schema_migrations (version) VALUES ('20091015055833');

INSERT INTO schema_migrations (version) VALUES ('20091016084740');

INSERT INTO schema_migrations (version) VALUES ('20091019065719');

INSERT INTO schema_migrations (version) VALUES ('20091019072823');

INSERT INTO schema_migrations (version) VALUES ('20091020085658');

INSERT INTO schema_migrations (version) VALUES ('20091027023838');

INSERT INTO schema_migrations (version) VALUES ('20091028083608');

INSERT INTO schema_migrations (version) VALUES ('20091102020101');

INSERT INTO schema_migrations (version) VALUES ('20091102024045');

INSERT INTO schema_migrations (version) VALUES ('20091216093520');

INSERT INTO schema_migrations (version) VALUES ('20091221083814');

INSERT INTO schema_migrations (version) VALUES ('20091224070345');

INSERT INTO schema_migrations (version) VALUES ('20091224085908');

INSERT INTO schema_migrations (version) VALUES ('20091229074446');

INSERT INTO schema_migrations (version) VALUES ('20100118070059');

INSERT INTO schema_migrations (version) VALUES ('20100130122503');

INSERT INTO schema_migrations (version) VALUES ('20100221083254');

INSERT INTO schema_migrations (version) VALUES ('20100226042129');

INSERT INTO schema_migrations (version) VALUES ('20100228092945');

INSERT INTO schema_migrations (version) VALUES ('20100302154253');

INSERT INTO schema_migrations (version) VALUES ('20100315062526');

INSERT INTO schema_migrations (version) VALUES ('20100317092118');

INSERT INTO schema_migrations (version) VALUES ('20100325082210');

INSERT INTO schema_migrations (version) VALUES ('20100401070508');

INSERT INTO schema_migrations (version) VALUES ('20100402095140');

INSERT INTO schema_migrations (version) VALUES ('20100430071123');

INSERT INTO schema_migrations (version) VALUES ('20100430072957');

INSERT INTO schema_migrations (version) VALUES ('20100503064115');

INSERT INTO schema_migrations (version) VALUES ('20100531140740');

INSERT INTO schema_migrations (version) VALUES ('20100621132442');

INSERT INTO schema_migrations (version) VALUES ('20100912050505');

INSERT INTO schema_migrations (version) VALUES ('20101101135035');

INSERT INTO schema_migrations (version) VALUES ('20101117140515');

INSERT INTO schema_migrations (version) VALUES ('20101128025207');

INSERT INTO schema_migrations (version) VALUES ('20101129145158');

INSERT INTO schema_migrations (version) VALUES ('20101204020035');

INSERT INTO schema_migrations (version) VALUES ('20101213131605');

INSERT INTO schema_migrations (version) VALUES ('20101218062831');

INSERT INTO schema_migrations (version) VALUES ('20101219044514');

INSERT INTO schema_migrations (version) VALUES ('20101229124858');

INSERT INTO schema_migrations (version) VALUES ('20110320060456');