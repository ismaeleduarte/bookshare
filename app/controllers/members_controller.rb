class MembersController < ApplicationController
  def index
    @members = User.all :order => 'RANDOM()', :limit => 30
  end

  def show
    @user = User.find_by_login(params[:login])

    if @user.nil?
      render :file => "#{Rails.root}/public/404.html", :status => :not_found
      return
    end

    respond_to do |format|
      format.html
      format.atom { render :layout => false } # show.atom.builder
    end
  end
end
