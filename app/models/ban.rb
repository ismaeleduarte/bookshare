class Ban < ActiveRecord::Base
  
  belongs_to  :user
  
  # Admin user doing the banning
  belongs_to  :banner,
              :class_name => "User",
              :foreign_key => :banner
              
  # Admin user doing the unbanning
  belongs_to  :unbanner,
              :class_name => "User",
              :foreign_key => :unbanner
  
  attr_accessible :user_id, :banner, :unbanner, :reason
  
  validates_presence_of :user, :banner, :reason
  
  validate :banner_must_be_admin, :on => :create
  validate :banner_must_not_be_banee, :on => :create
  validate :banee_must_not_already_be_banned, :on => :create
  validate :banee_must_not_be_admin, :on => :create
  
  after_create :set_user_as_banned
  
  protected
  
  def set_user_as_banned
    @user = self.user
    @user.banned = true
    @user.save
  end
  
  def banner_must_be_admin
    errors.add(:banner, "must be an admin") unless banner && banner.admin?
  end

  def banner_must_not_be_banee
    errors.add(:banner, "cannot ban themselves") if banner == user
  end

  def banee_must_not_already_be_banned
    errors.add(:user, "is already banned") if user && user.banned?
  end

  def banee_must_not_be_admin
    errors.add(:user, "cannot ban an admin") if user && user.admin?
  end
  
end
