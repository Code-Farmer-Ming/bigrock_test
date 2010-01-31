require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/js/auto_complete_like_facebook.js"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/css/auto_complete_like_facebook.css"),File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/imges/"),File.join(File.dirname(__FILE__),"..","..","..","public","images","auto_complete_like_facebook"))