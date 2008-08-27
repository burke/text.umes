class BooksController < ApplicationController

  # GET /books/search
  # GET /books/search.xml
  def search
  end

  # GET /books/list
  # GET /books/list.xml
  def list
    if params[:query]
      @searched = true
      @books = Book.active.search(params[:query])
    else
      @books = Book.active_reverse.paginate :page => params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books }
    end
  end

  def index
    redirect_to :action => 'list'
  end
  
  
  # GET /books/1
  # GET /books/1.xml
  def show
    @book = Book.active.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @book }
    end
  end

  
  # GET /books/new
  # GET /books/new.xml
  def new
    @book = Book.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end

  # POST /books
  def create
    @book = Book.new(params[:book])
    @book.salt = rand.to_s[2..15]
    
    if @book.save
      Notifier.deliver_book_confirmation(@book)
      flash[:notice] = 'Book was successfully created. Check your email for the confirmation code.'
      redirect_to '/books/list'
    else
      render :action => "new"
    end
  end


  def confirm
    @book = Book.find(params[:id])
    key = params[:k]

    if key == @book.confirmation_code
      @book.update_attributes!({:confirmed => true})
      flash[:notice] = "Your book has been confirmed!"
      redirect_to @book
    else
      flash[:errors] = "You supplied an invalid confirmation code. Maybe you copied and pasted wrong?"
      redirect_to '/books/list'
    end
  end

  def remove
    @book = Book.find(params[:id])
    key = params[:k]

    if key == @book.removal_code
      @book.update_attributes!({:disabled => true})
      flash[:notice] = "Your book has been removed!"
      redirect_to '/books/list'
    else
      flash[:errors] = "You supplied an invalid removal code. Maybe you copied and pasted wrong?"
      redirect_to '/books/list'
    end
  end


  def contact

    @book = Book.find(params[:id])
    if params[:buyer] !~ /^um[a-z0-9]{2,8}/
      flash[:errors] = "You must specify a valid UMNetID."
      redirect_to @book
    else
      Notifier.deliver_message(@book,params[:message],params[:buyer])
      flash[:notice] = 'Message was sent to seller. Now you play the waiting game.'
      redirect_to '/books/list'
    end
  end

end
