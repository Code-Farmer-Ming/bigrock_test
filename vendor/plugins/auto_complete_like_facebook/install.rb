require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/js/prototype_ui_auto_complete_like_facebook/"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/css/auto_complete_like_facebook.css"),File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/images/default/"),File.join(File.dirname(__FILE__),"..","..","..","public","images","auto_complete_like_facebook"))