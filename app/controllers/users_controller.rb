class UsersController < ApplicationController

  def index
   # findメソッドは引数を受け取り、idカラムを引数と比べてレコードを取得してくるメソッド。(allメソッドはid関係なく全て取得してくる)
   @user = User.find(current_user.id)
   # モデルの情報をform_withに渡す。
    # このnewはこのコントローラに定義されてるnewアクションの事ではなく、allと同じでモデルに元々備わってるメソッド機能の一つ。
   @newbook = Book.new
   @users = User.all
  end

  def show
    # URLに記載されたIDを参考に、必要なUserモデルを取得する処理。
    # findメソッドは引数を受け取り、idカラムを引数と比べてレコードを取得してくるメソッド。(allメソッドはid関係なく全て取得してくる)
    # 取得したデータ1つをインスタンス変数に格納し、そのインスタンス変数をviewファイルで利用して詳細画面を表示する。
    # リンクの設定はshow.html.erb内にlink_toメソッドを用いる事で設定する。
   @user = User.find(params[:id])
   # モデルの情報をform_withに渡す。
    # このnewはこのコントローラに定義されてるnewアクションの事ではなく、allと同じでモデルに元々備わってるメソッド機能の一つ。
   @newbook = Book.new
   # アソシエーションを持っているモデル同士の記述方法。共通カラムであるuser_idを元に、ユーザ(@user)に関連付けられた投稿全て(.books)を取得し、
    # @booksに渡すという処理を行うことが出来る。結果、全体の投稿ではなく、個人が投稿したもの全てを表示出来るようになる。
    # Userモデルはデフォルトでuser_idを持ってるし、Bookモデルにもマイグレーションファイルにt.integer :user_idが定義されているので、
    # その共通カラムを検索情報に使って、そのuser_idを持つ投稿データ全てだけを取得する事が出来る。
    # 変更前は@books = @user.booksだった。これだと、そのIDのuserが投稿したbooksテーブル内の全データが際限なく取得&表示されてしまう。
    # これを、1ページ分の決められた数のデータだけを、新しい順に取得するように変更している。
    # pageメソッドは、kaminariをインストールしたことで使用可能になったメソッド。
    # @books = @user.books.allにすべき？
   @books = @user.books.all
  end

  def edit
   # URLに記載されたIDを参考に、必要なUserモデルを取得する処理。
    # 投稿済みのデータを編集するため、保存されているデータをfindメソッドを用いて取得する。
    # リンクの設定はedit.html.erb内にlink_toメソッドを用いる事で設定する。
   @user = User.find(params[:id])
   # URLのユーザID(@user.id)が現在ログイン中のユーザIDと「一致しない」場合、ログイン中のユーザの詳細画面へ遷移する。
   unless @user.id == current_user.id
    redirect_to user_path(current_user.id)
   end
  end

  def update
   # 投稿済みのデータを編集するため、保存されているデータをfindメソッドを用いて取得する
   @user = User.find(params[:id])
   # user_paramsメソッドを用いてフォームから入力されたデータを受け取り、updateメソッドで既存の投稿内容を更新。
   if @user.update(user_params)
    # 投稿に成功した場合のフラッシュメッセージ
      # flashオブジェクトのキーである[:notice]に表示したいメッセージをvalueとして追加。
    flash[:notice] = 'You have updated user successfully.'
    # 詳細画面(show.html.erb)へ画面遷移（リダイレクト）。
      # 「転送したいアクションへのURL→user_path(user.id)を指定(名前付きルートを使用)」する事でshowアクション、show.html.erb(詳細画面)へリダイレクト。
    redirect_to user_path(@user.id)
   else
     # render…アクション名。同じコントローラ内の別アクションのviewを表示出来る。
      # renderは直接ビューファイルを表示させている。 そのため画面の遷移はなく、表示されているHTMLが入れ替わるのみ。
      # renderとredirect_toの違いについては「アプリケーションを完成させよう 9章」参照。
      # 大きな違いとして、renderは「アクションを新たに実行しない」、redirect_toは「アクションを新たに実行する」という違いがある。
    render :edit
     # renderは直接viewファイルを表示するので、「そのviewファイルに必要なインスタンス変数」は、予めrenderの前に用意する必要があるから。
      # バリデーション実装に伴うアクションの処理変更の際は、エラー発生の場合の処理として、renderとその遷移先で必要となる変数の定義を必ずする事。
      # ただし、エラー情報を持った変数についてはノータッチ。誤って再定義し直してエラー情報を上書きしないようにする事。
      # 上記のrender :newの部分でredirect_toを使うとnewアクション内で再度@book = Book.newが実行されるため、
      # @bookが上書きされてエラーメッセージが消えてしまう。基本的に、エラーメッセージを扱う際はrender、それ以外はredirect_toを使うと覚えること。
   end
  end

  private
  # ストロングパラメータというフォームから入力されたデータを受け取る仕組み(「アプリケーションを完成させよう」2章の後半参照)。脆弱性対策。
  # モデル名_params…メソッド名。(今回はbook_params)このメソッドをここに書く理由については、2章の後半(メソッドの呼び出しに制限をかける)参照。
  # ーーーーーーーーーーーーparams…フォームから送られてくるデータが入っている。ーーーーーーーーーーーー
  # require…送られてきたデータの中からモデル名(ここでは:book)を指定し、データを絞り込む。(モデル名での絞り込みであってtitleやbodyといったカラムの指定、絞り込みはしてない)
  # permit…require(モデル名の条件)で絞り込んだデータの中から、取得や保存を許可するカラムを指定する。
  # requireやpermitでモデル名やカラムの指定、絞り込みをするのは、「悪意あるユーザーが改竄したデータを保存しないようにする」為。
  def user_params
    params.require(:user).permit(:name, :profile_image, :introduction)
  end
end