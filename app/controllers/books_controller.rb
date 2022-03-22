class BooksController < ApplicationController


  def new
    @book = Book.new
  end
  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    @user = current_user
    @books = Book.all
    if @book.save
      flash[:notice] = "successfully"
      redirect_to book_path(@book.id)
    else
      render :index
    end
  end

  def index
    @books = Book.all
    @user = current_user
    @book = Book.new
  end

  def show
    @book = Book.find(params[:id])
    @bookk = Book.new
    @user = @book.user
  end

  def destroy
    @book = destroy.Book(params[:id])
    @book.destroy
    redirect_to Books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end
end
