# Install hook code here
require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/js/fabtabulous.js"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/css/tabs.css"),File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/images/tableft1.gif"),File.join(File.dirname(__FILE__),"..","..","..","public","images"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/images/tabright1.gif"),File.join(File.dirname(__FILE__),"..","..","..","public","images"))