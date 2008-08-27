class Book < ActiveRecord::Base

  cattr_reader :per_page
  @@per_page = 20

  define_index do
    set_property :delta => true
    indexes title,  :sortable => true
    indexes author, :sortable => true
    indexes isbn
  end

  validates_presence_of :title, :author

  # Make sure the seller is present and is a valid umnetid.
  validates_presence_of :seller
  validates_format_of   :seller,
    :with => /^um[a-z0-9]{2,8}/,
    :message => "must be a valid <a href=\"http://webware.cc.umanitoba.ca/twiki/bin/view/Main/UMnetID\">UMNetID.</a>"

  validates_presence_of :price
  validates_numericality_of :price
  
  validates_format_of :isbn,
    :with => /^[0-9]-?[0-9]{3}-?[0-9]{5}-?[0-9]$/,
    :message => "must be a valid ISBN-10"

  def validate
    if price <= 0
      errors.add(:price, "must be positive.")
      end
  end
  
  def isbn=(_isbn)
    write_attribute(:isbn, format_isbn(_isbn))
  end

  # Download the cover from Amazon.
  def after_save
    return if File.exists?("#{RAILS_ROOT}/public/images/cover-sm/#{isbn}.jpg")
    Net::HTTP.start("images.amazon.com") do |http|
      resp = http.get("/images/P/#{isbn.gsub('-','')}.01.TZZZZZZZ.jpg")
      open("#{RAILS_ROOT}/public/images/cover-sm/#{isbn}.jpg",'w') do |file|
        file.write(resp.body)
      end
      resp = http.get("/images/P/#{isbn.gsub('-','')}.01.MZZZZZZZ.jpg")
      open("#{RAILS_ROOT}/public/images/cover/#{isbn}.jpg",'w') do |file|
        file.write(resp.body)
      end
    end
  end

  def confirmation_link
    "http://text.umes.mb.ca/books/confirm/#{id}?k=#{confirmation_code}"
  end

  def removal_link
    "http://text.umes.mb.ca/books/remove/#{id}?k=#{removal_code}"
  end

  def confirmation_code
    Digest::SHA1.hexdigest("#{title}#{isbn}#{seller}#{salt}")
  end

  def removal_code
    Digest::SHA1.hexdigest("#{title}disable#{isbn}#{seller}#{salt}")
  end

  def thumbnail_url
    "/images/cover-sm/#{isbn}.jpg"
  end

  def image_url
    "/images/cover/#{isbn}.jpg"
  end
  
  private ####################################################################
  def numericalize_isbn(_isbn)
    return _isbn.gsub(/[^0-9]/,'')
  end

  # Wow, pack/unpack is sexy. Format the ISBN in the standard format.
  def format_isbn(_isbn)
    _isbn_num = numericalize_isbn(_isbn)
    if _isbn_num.size == 10
        return _isbn_num.unpack('A1A3A5A1').join('-')
    else
      return _isbn
    end
  end

  named_scope :active_reverse,
    :conditions => { :confirmed => true, :disabled => nil },
    :order => 'ID DESC'

  named_scope :active,
    :conditions => { :confirmed => true, :disabled => nil }


end
