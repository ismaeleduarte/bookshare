class PagesController < ApplicationController
  def home
    @books = Book.all(
      :conditions => { :status => StaticData::BOOK_STATUS['AVAILABLE'] },
      :order => 'RANDOM()',
      :limit => 30
    )
  end
  
  def contact
  end
  
  def accessibility
  end
end
