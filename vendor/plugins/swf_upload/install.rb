require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/js/swfupload.js"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/flash/swfupload.swf"),File.join(File.dirname(__FILE__),"..","..","..","public","flash"))
