class PublishsController < ApplicationController
  before_filter :check_login?

  def create
    @my_language = MyLanguage.new(params[:my_language])
    current_user.my_languages << @my_language   
  end

  def destroy
    @my_language = current_user.my_languages.find(params[:id])
    @log_item = @my_language.log_item
    @my_language.destroy
  end

end
