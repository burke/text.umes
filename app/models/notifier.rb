class Notifier < ActionMailer::Base

  def book_confirmation( book )
    recipients "#{book.seller}@cc.umanitoba.ca"
    from "noreply@umes.mb.ca"
    subject "Confirm your listing on text.umes.mb.ca"

    body :book => book
  end

  def message( book, message, buyer )
    recipients "#{book.seller}@cc.umanitoba.ca"
    from "noreply@umes.mb.ca"
    subject "UMES Textbook Exchange: Mail for #{book.title}"

    body :book => book, :message => message, :buyer => buyer
    
  end
  
end
