Technoweenie::AttachmentFu::InstanceMethods.module_eval do

  # Overriding this method to allow content_type to be detected when
  # swfupload submits images with content_type set to 'application/octet-stream'
  def uploaded_data_with_mimetype_detection=(file_data)
    file_data.content_type = File.mime_type?(file_data.original_filename)
    upload_results = self.uploaded_data_without_mimetype_detection=file_data
    if upload_results && file_data.content_type.strip == "application/octet-stream"
      self.content_type = File.mime_type?(file_data.original_filename)
    end
    return upload_results
  end
  alias_method_chain :uploaded_data=, :mimetype_detection
  
  protected

  # Downcase and remove extra underscores from uploaded images
  def sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''
    
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^A-Za-z0-9\.\-]/, '_'
    
      # Remove multiple underscores
      name.gsub!(/\_+/, '_')
  
      # Downcase result including extension
      name.downcase!
    end
  end
end


Technoweenie::AttachmentFu::Backends::FileSystemBackend.module_eval do
  # Force tests to use a temporary directory instead of the project's public directory
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    File.join(env_dir, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  # Use this to override the default directory when in test mode
  def env_dir
    RAILS_ENV == "test" ? Dir::tmpdir() : RAILS_ROOT
  end
end
