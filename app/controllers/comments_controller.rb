class CommentsController < ApplicationController
  before_filter :check_login?
  in_place_edit_for :comment,:content
  
  def destroy
    if params[:topic_id] #topic
      owner = Topic.find(params[:topic_id])
    else#新闻 news
      owner = Piecenews.find(params[:piecenews_id])
      
    end
    @comment =  owner.comments.find(params[:id])
    @comment.destroy
  end

  def create
    @comment = Comment.new(params[:comment])
    if params[:topic_id]
      owner = Topic.find(params[:topic_id])
      owner.last_comment_datetime = Time.now
      if owner.owner_type!="Group"
        @comment.user = current_user.get_account(params[:alias])
      else #owner.owner 是 group
        @comment.user = owner.owner.all_members.first(:conditions=>["users.id in (?)", current_user.ids])
      end
    else #新闻 news
      owner = Piecenews.find(params[:piecenews_id])
      @comment.user = current_user.get_account(params[:alias])
    end
    owner.comments << @comment
  end
  #顶
  def up
    @comment = Comment.find(params[:id])
    @comment.votes << Vote.new(:value=>1,:user=>current_user)
    @comment.up += 1
    @comment.save
    render :partial => "comm_partial/update_up_down_panel",:object=>@comment
  end
  #踩
  def down
    @comment = Comment.find(params[:id])
    @comment.down += 1
    @comment.votes << Vote.new(:value=>-1,:user=>current_user)
    @comment.save
    render :partial => "comm_partial/update_up_down_panel",:object=>@comment
  end
  #  def set_comment_content
  #    unless [:post, :put].include?(request.method) then
  #      return render(:text => 'Method not allowed', :status => 405)
  #    end
  #    if !params[:value]
  #      render :text => ""
  #    else
  #      @item = User.find(params[:id])
  #      @item.my_languages << MyLanguage.new(:content=>params[:value])
  #      render :text => CGI::escapeHTML(@item.my_language)
  #    end
  #  end
end
