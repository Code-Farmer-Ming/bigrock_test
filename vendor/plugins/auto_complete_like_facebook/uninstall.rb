require 'fileutils'
FileUtils.rm_r(File.join(File.dirname(__FILE__),"..","..","..","public","javascripts/prototype_ui_auto_complete_like_facebook/"), true)
FileUtils.remove_file(File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets/auto_complete_like_facebook.css"), true)
FileUtils.rm_r(File.join(File.dirname(__FILE__),"..","..","..","public","images/auto_complete_like_facebook/"), :force => true )