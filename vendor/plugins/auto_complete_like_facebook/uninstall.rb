FileUtils.remove_file(File.join(File.dirname(__FILE__),"..","..","..","public","javascripts/auto_complete_like_facebook.js"), true)
FileUtils.remove_file(File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets/auto_complete_like_facebook.css"), true)
FileUtils.rm_r(File.join(File.dirname(__FILE__),"..","..","..","public","images/auto_complete_like_facebook/"), :force => true )