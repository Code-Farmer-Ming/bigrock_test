class CommentsController < ApplicationController
  before_filter :check_login?
  in_place_edit_for :comment,:content
  
  def destroy
    if params[:topic_id] #topic
      owner = Topic.find(params[:topic_id])
    else#公司博客 news
      owner = Piecenews.find(params[:piecenews_id])
      
    end
    @comment =  owner.comments.find(params[:id])
    @comment.destroy
  end

  def create
    @comment = Comment.new(params[:comment])
    if params[:topic_id]
      owner = Topic.find(params[:topic_id])
      
      if owner.owner_type!="Group"
        @comment.user = current_user.get_account(params[:alias])
      else #owner.owner 是 group
        @comment.user = owner.owner.is_member?(current_user)
      end
    else #公司博客 news
      owner = Piecenews.find(params[:piecenews_id])
      @comment.user = current_user.get_account(params[:alias])
    end  
    if !owner.add_comment(@comment)
      flash.now[:error] =  @comment.errors.full_messages.to_s
    end

  end
  #顶
  def up
    @comment = Comment.find(params[:id])
    @comment.add_vote(Vote.new(:value=>1,:user=>current_user))
    render :partial => "comm_partial/update_up_down_panel",:object=>@comment
  end
  #踩
  def down
    @comment = Comment.find(params[:id])
    @comment.add_vote(Vote.new(:value=>-1,:user=>current_user))
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
