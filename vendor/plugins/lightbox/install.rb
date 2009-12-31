# Install hook code here
require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"javascripts/lightbox.js"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"stylesheets/lightbox.css"),File.join(File.dirname(__FILE__),"..","..","..","public","stylesheets"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"images/loading.gif"),File.join(File.dirname(__FILE__),"..","..","..","public","images"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"images/close.gif"),File.join(File.dirname(__FILE__),"..","..","..","public","images"))