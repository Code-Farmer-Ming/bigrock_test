require 'fileutils'
FileUtils.remove_file(File.join(File.dirname(__FILE__),"..","..","..","public","javascripts/swfupload.js"), true)
FileUtils.remove_dir(File.join(File.dirname(__FILE__),"..","..","..","public","flash"),true)
