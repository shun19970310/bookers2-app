class BooksController < ApplicationController
  def create
   @book = Book.new(book_params)
   @book.user_id = current_user.id
   if @book.save
    flash[:notice] = 'You have created book successfully.'
    redirect_to book_path(@book.id)
   else
    @books = Book.all
    @user = User.find(current_user.id)
    @newbook = Book.new
     render :index
   end
  end

  def index
   @book = Book.new
   @user = User.find(current_user.id)
   @newbook = Book.new
   @books = Book.page(params[:page])
  end

  def show
   @newbook = Book.new
   @book = Book.find(params[:id])
   @user = @book.user
  end

  def edit
   @book = Book.find(params[:id])
   unless @book.user.id == current_user.id
    redirect_to books_path
   end
  end

  def update
   @book = Book.find(params[:id])
   if @book.update(book_params)
   flash[:notice] = 'You have updated book successfully.'
    redirect_to book_path(@book.id)
   else
    render :edit
   end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to '/books'
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :user_id)
  end
end
