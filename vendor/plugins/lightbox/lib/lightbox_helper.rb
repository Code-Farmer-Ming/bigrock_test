# To change this template, choose Tools | Templates
# and open the template in the editor.

module LightboxHelper
  def link_to_remote_lightbox(name, link_to_remote_options = {}, html_options = {})
    @uses_redbox = true

    html_options = {  :onclick=>"Lightbox.show('#{url_for(link_to_remote_options[:url])}')"}.merge!( html_options);

    return  link_to(name, "#", html_options)
  end

  def link_to_close_lightbox(name, html_options = {})
    @uses_redbox = true
    link_to_function name, 'Lightbox.close()', html_options
  end

  def button_to_close_lightbox(name, html_options = {})
    @uses_redbox = true
    button_to_function name, 'Lightbox.close()', html_options
  end
    
end
