class MessagesController < ApplicationController
  before_filter :require_user
  
  def new
    @recipient = User.find_by_login(params[:recipient])
    redirect_to root_url, :alert => "User not found" if @recipient.nil?
  end

  def create
    @to = User.find_by_login(params[:recipient])
    if @to.nil?
      redirect_to root_url, :alert => "User not found"
      return
    end
    @from = current_user
    @message = params[:message].strip

    if @message.length > 0
      email = MemberMessage.member_message(@from, @to, @message)
      if email.deliver
        redirect_to :back, :notice => "Message sent to #{@to.login} OK"
      else
        redirect_to :back, :alert => "Failed to send message"
      end
    else
      redirect_to :back, :alert => "No message to send"
    end
  end

  def request_new
    @recipient = User.find_by_login(params[:recipient])
    if @recipient.nil?
      redirect_to root_url, :alert => "User not found"
      return
    end
    @book = Book.find(params[:book])
  end

  def request_create
    @to = User.find_by_login(params[:recipient])
    if @to.nil?
      redirect_to root_url, :alert => "User not found"
      return
    end
    @from = current_user
    @book = Book.find(params[:book])
    @message = params[:message].strip

    if @message.length > 0
      email = MemberMessage.book_request(@from, @to, @book, @message)
      if email.deliver
        redirect_to :back, :notice => "Request sent to #{@to.login} OK"
      else
        redirect_to :back, :alert => "Failed to send request"
      end
    else
      redirect_to :back, :alert => "No message to send"
    end
  end


end
