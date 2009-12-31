require 'fileutils'

FileUtils.cp_r(File.join(File.dirname(__FILE__),"files/js/text_field_default_value.js"),File.join(File.dirname(__FILE__),"..","..","..","public","javascripts"))
