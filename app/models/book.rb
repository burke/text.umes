class Book < ActiveRecord::Base

  # Make sure the seller is present and is a valid umnetid.
  validates_presence_of :seller
  validates_format_of   :seller,
    :with => /^um[a-z0-9]{2,8}/,
    :message => "must be a valid <a href=\"http://webware.cc.umanitoba.ca/twiki/bin/view/Main/UMnetID\">UMNetID.</a>"

  validates_presence_of :price
  validates_numericality_of :price
  
  def validate
    isbn_min = numericalize_isbn(isbn)
    if isbn_min.size != 10 and isbn_min.size != 13 and isbn.size != 0
      errors.add_to_base("If you specify an ISBN, it must be valid.")
    end
  end

  def isbn=(_isbn)
    write_attribute(:isbn, format_isbn(_isbn))
  end

  private ####################################################################
  def numericalize_isbn(_isbn)
    return _isbn.gsub(/[^0-9]/,'')
  end

  # Wow, pack/unpack is sexy. Format the ISBN in the standard format.
  def format_isbn(_isbn)
    _isbn = numericalize_isbn(_isbn)
    case _isbn.size
    when 10:
        return _isbn.unpack('A1A3A5A1').join('-')
    when 13:
        return _isbn.unpack('A3A1A3A5A1').join('-')
    else
      return ""
    end
  end
  
end
