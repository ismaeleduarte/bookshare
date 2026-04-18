class BansController < ApplicationController

  before_filter :require_admin

  # GET /bans
  # GET /bans.xml
#   def index
#     @bans = Ban.all
# 
#     respond_to do |format|
#       format.html # index.html.erb
#       format.xml  { render :xml => @bans }
#     end
#   end

  # GET /bans/1
  # GET /bans/1.xml
#   def show
#     @ban = Ban.find(params[:id])
# 
#     respond_to do |format|
#       format.html # show.html.erb
#       format.xml  { render :xml => @ban }
#     end
#   end

  # GET /bans/new
  # GET /bans/new.xml
  def new
    @ban = Ban.new
    @user = User.find_by_login(params[:login])

    if @user.nil?
      redirect_to :back, :alert => "User not found"
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ban }
    end
  end

  # POST /bans
  # POST /bans.xml
  def create
    @ban = Ban.new
    @ban.user = User.find_by_login(params[:ban][:login])

    if @ban.user.nil?
      redirect_to :back, :alert => "User not found"
      return
    end
    @ban.reason = params[:ban][:reason]
    @ban.banner = current_user

    respond_to do |format|
      if @ban.save
        format.html { redirect_to(:back, :notice => "#{@ban.user.name} (#{@ban.user.login}) has now been banned.") }
#         format.xml  { render :xml => @ban, :status => :created, :location => @ban }
      else
        format.html { render :action => "new" }
#         format.xml  { render :xml => @ban.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bans/1
  # PUT /bans/1.xml
#   def update
#     @ban = Ban.find(params[:id])
# 
#     respond_to do |format|
#       if @ban.update_attributes(params[:ban])
#         format.html { redirect_to(@ban, :notice => 'Ban was successfully updated.') }
#         format.xml  { head :ok }
#       else
#         format.html { render :action => "edit" }
#         format.xml  { render :xml => @ban.errors, :status => :unprocessable_entity }
#       end
#     end
#   end

end
