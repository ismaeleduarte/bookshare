require 'digest/md5'

class User < ActiveRecord::Base
  has_many :books
  has_many :titles, :through => :books

  has_many :watchings
  has_many :watched_books, :through => :watchings, :source => :book
  
  has_many  :borrowings,
            :class_name => "Loan",
            :foreign_key => :borrower_id
            
  has_many  :loans,
            :class_name => "Loan",
            :foreign_key => :lender_id
            
  has_many  :active_borrowings,
            :class_name => "Loan",
            :foreign_key => :borrower_id,
            :conditions => { :returned => nil },
            :order => 'created_at DESC'
            
  has_many  :active_loans,
            :class_name => "Loan",
            :foreign_key => :lender_id,
            :conditions => { :returned => nil },
            :order => 'created_at DESC'
  
  has_many  :bans            
  
  has_many  :bannings,
            :class_name => "Ban",
            :foreign_key => :banner
            
  has_many  :unbannings,
            :class_name => "Ban",
            :foreign_key => :unbanner
            
  validates_presence_of :first_name, :last_name, :address1, :city, :postcode
  
  after_create :send_registration_confirmation, :promote_first_user
  
  attr_protected :status, :banned

  attr_accessible :login, :email, :first_name, :last_name, :address1, :address2, :city, :county, :postcode, :phone, :password, :password_confirmation
    
  def to_param
    login
  end

#   http://www.binarylogic.com/2008/11/16/tutorial-reset-passwords-with-authlogic/
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    MemberMessage.password_reset_instructions(self).deliver
  end 
  
  # http://littleshardsofruby.posterous.com/changing-authlogics-login-field
  acts_as_authentic do |c|
    c.validates_format_of_login_field_options = {:with => /^[a-zA-Z0-9]+$/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters and numbers")}   
    c.validates_length_of_login_field_options = {:within => 5..20} 
  end
  
  def gravatar_image_url(size = 40)
    "http://www.gravatar.com/avatar/" + Digest::MD5.hexdigest(self.email.strip.downcase) + "?d=identicon&s=" + size.to_s
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def promote
    update_attribute(:status, 'admin')
  end
  
  def demote
    update_attribute(:status, 'user')
  end

  def self.admins
    User.find_all_by_status('admin', :order => :login)
  end

  def self.banned
    User.find_all_by_banned_and_status(true, 'user', :order => :login) # It's implicit that status will be 'user' as admins can't be banned
  end

  def self.non_admins
    User.find_all_by_banned_and_status(false, 'user', :order => :login)
  end
  
  def owns?(book)
    self.books.include?(book)
  end
  
  # Can this user watch this book?
  def watched?(book)
    # Not if they're already watching it
    self.watched_books.include?(book)
  end
  
  def admin?
    self.status == 'admin'
  end
  
  def unban(unbanner)
    unless self.banned?
      return false
    end
  
    unless unbanner.admin?
      return false
    end
    
    @ban = self.bans.last
    @ban.unbanner = unbanner
    @ban.unbanned_at = Time.now

    if @ban.save
      self.banned = false
      self.save
      return true
    else
      return false
    end
  end
  
  protected
  
  def send_registration_confirmation
    email = MemberMessage.registration_confirmation(self)
    email.deliver
  end
  
  # When setting up a new site make the first registered user an admin
  def promote_first_user
    if 1 == User.count
      User.first.promote
    end
  end
end
