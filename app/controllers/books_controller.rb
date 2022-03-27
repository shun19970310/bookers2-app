class BooksController < ApplicationController
 # データを追加（保存）する役割のアクション
  def create
   # フォームに入力したデータを受け取り、それを元に、新規登録するためのインスタンスを作成。
    # Book(Model)のメソッドであるnewメソッドが呼び出され、引数でbook_paramsメソッドが呼び出されている。
    # book_paramsを引数にする事で絞り込んだデータを受け取り、それを元にnewメソッドでインスタンスを作ってる。
    # ここでやってるのは絞り込んだデータを元にしたインスタンス生成であって保存ではない。book_paramsはデータを絞り込むだけで保存はしない。
    # このnewはこのコントローラに定義されてるnewアクションの事ではなく、allと同じでモデルに元々備わってるメソッド機能の一つ。
   @book = Book.new(book_params)
   # @book.user_id,つまり「この投稿のuser_idとしてcurrent_user.idの値を代入する」という意味。
    # current_userはコードに記述する事でログイン中のユーザー情報を取得出来る。ここではログインユーザー(current_user)のidを取得している。
    # current_userはヘルパーメソッドと呼ばれるものの一種で、deviseをインストールすることで使用可能。
    # 要するにここの処理内容は、「@book(投稿データ)のuser_idを、current_user.id(今ログインしているユーザーのID)に
    # 指定することで、投稿データ(@book)に今ログイン中のユーザーのIDを持たせている」というもの。
   @book.user_id = current_user.id
   # 上記で生成したインスタンスにsaveメソッド(インスタンスをデータベースに保存するメソッド)を使い、データをデータベースに保存する。
    # バリデーションの結果を、コントローラで検出できるようにする。(if文を用いる)
    # book.rb(モデルファイル)にバリデーションチェックを設定しているため、saveメソッドが走った際、trueかfalseが返ってくる。
    # 対象のカラムにデータが入力されていた場合はtrueが返ってくる。この場合、次に表示したいページにリダイレクトさせる。
    # 対象のカラムにデータが入力されていなかった場合はfalseが返ってくる。この場合、新規投稿ページを再表示させる。
   if @book.save
    # 投稿に成功した場合のフラッシュメッセージ
    # flashオブジェクトのキーである[:notice]に表示したいメッセージをvalueとして追加。
    flash[:notice] = 'You have created book successfully.'
    # 「転送したいアクションへのURL」をbook_path(book.id)に指定する事でshowアクションが働き、show.html.erbを探し出してそこへ遷移する。
    # book_pathの「book」はshowアクションの名前付きルートの名称で、def show(showアクション)の処理を行ってくれる。
    redirect_to book_path(@book.id)
   else
    # render…アクション名。同じコントローラ内の別アクションのviewを表示出来る。
    # renderは直接ビューファイルを表示させている。 そのため画面の遷移はなく、表示されているHTMLが入れ替わるのみ。
    # renderとredirect_toの違いについては「アプリケーションを完成させよう 9章」参照。
    # 大きな違いとして、renderは「アクションを新たに実行しない」、redirect_toは「アクションを新たに実行する」という違いがある。
    @books = Book.all
    # 部分テンプレートで用いる変数もちゃんと再定義するのを忘れずに。
    # @newbook = Book.newを定義しなかった場合、入力フォームの表示までは問題なく出来るが、入力内容の投稿は出来なくなる。
    # 理由は、form_withで入力内容を格納するローカル変数newbookに、@newbookからのモデル情報が入っていない空の状態になってしまうから。
    # f.text_fieldやf.text_areaで入力した内容はnewbookに格納されてDBへ送られるので、格納先のnewbookにモデル情報が入ってないと送る事が出来ずエラーになる。
    @user = User.find(current_user.id)
    @newbook = Book.new
     render :index
      # newからindexに変更する際は、renderの直前に「@books = Book.all」を設定すること。理由は以下の通り。
      # renderは直接viewファイルを表示するので、「そのviewファイルに必要なインスタンス変数」は、予めrenderの前に用意する必要があるから。
      # バリデーション実装に伴うアクションの処理変更の際は、エラー発生の場合の処理として、renderとその遷移先で必要となる変数の定義を必ずする事。
      # ただし、エラー情報を持った変数についてはノータッチ。誤って再定義し直してエラー情報を上書きしないようにする事。
      # 上記のrender :newの部分でredirect_toを使うとnewアクション内で再度@book = Book.newが実行されるため、
      # @bookが上書きされてエラーメッセージが消えてしまう。基本的に、エラーメッセージを扱う際はrender、それ以外はredirect_toを使うと覚えること。
   end
  end

  def index
   # errorsメソッドで用いている変数が空にならないようモデルの情報を入れておいてやる。
   @book = Book.new
   # 現在ログインしているユーザーのIDを元に、必要なUserモデルを取得する処理。
    # findメソッドは引数を受け取り、idカラムを引数と比べてレコードを取得してくるメソッド。(allメソッドはid関係なく全て取得してくる)
    # 取得したデータ1つをインスタンス変数に格納し、そのインスタンス変数をviewファイルで利用して画面を表示する。
    # リンクの設定はindex.html.erb内にlink_toメソッドを用いる事で設定する。
   @user = User.find(current_user.id)
    # モデルの情報をform_withに渡す。
    # このnewはこのコントローラに定義されてるnewアクションの事ではなく、allと同じでモデルに元々備わってるメソッド機能の一つ。
   @newbook = Book.new
   # Book.allではBookテーブル内の全データが取得されていたが、
    # これを、1ページ分の決められた数のデータだけを、新しい順に取得するように変更している。
    # pageメソッドは、kaminariをインストールしたことで使用可能になったメソッド。
   @books = Book.page(params[:page])
  end

  def show
   # モデルの情報をform_withに渡す。
    # このnewはこのコントローラに定義されてるnewアクションの事ではなく、allと同じでモデルに元々備わってるメソッド機能の一つ。
   @newbook = Book.new
   @book = Book.find(params[:id])
    # findメソッドは引数を受け取り、idカラムを引数と比べてレコードを取得してくるメソッド。
    # 以下の記述だと、どの本の詳細を開いたとしてもその本の投稿主ではなく、現在ログイン中のユーザの情報が表示されるようになってしまう。
    # @user = User.find(current_user.id)
    # 以下の記述だと、URLに記載されたIDを元にUserモデルを取得してしまうので、「URLのID(本の番号)が3だからユーザID3番の情報を取得してくる」
    # という動作になってしまい、正しくその本の投稿主のユーザ情報を取得できない処理内容になってしまう。
    # @user = User.find(params[:id])
    # 以下のコードは、@book = Book.find(params[:id])より下の行に書かないと、@bookに何も入ってない状態になり、エラーが起きる。
   @user = @book.user
  end

  def edit
   # 投稿済みのデータを編集するため、保存されているデータをfindメソッドを用いて取得する
   @book = Book.find(params[:id])
   # 「URLのbookIDのbookを投稿したユーザ(@book.user.id)」が「現在ログイン中のユーザ」と「一致しない」場合、booksの一覧画面へ遷移する。
    # その本を投稿した人自身しか、本の情報を編集出来ないように設定する。
   unless @book.user.id == current_user.id
    redirect_to books_path
   end
  end

  def update
   # 投稿済みのデータを編集するため、保存されているデータをfindメソッドを用いて取得する
   @book = Book.find(params[:id])
   # book_paramsメソッドを用いてフォームから入力されたデータを受け取り、updateメソッドで既存の投稿内容を更新。
    # バリデーションの結果を、コントローラで検出できるようにする。(if文を用いる)
    # book.rb(モデルファイル)にバリデーションチェックを設定しているため、updateメソッドが走った際、trueかfalseが返ってくる。
    # 対象のカラムにデータが入力されていた場合はtrueが返ってくる。この場合、次に表示したいページにリダイレクトさせる。
    # 対象のカラムにデータが入力されていなかった場合はfalseが返ってくる。この場合、編集ページを再表示させる。
   if @book.update(book_params)
    # ここでユーザーが入力した内容を受け取ってる。(空かどうかもここで確認してる)
      # 更新に成功した場合の処理。(フラッシュメッセージが表示される)
      # flashオブジェクトのキーである[:notice]に表示したいメッセージをvalueとして追加。
   flash[:notice] = 'You have updated book successfully.'
   # 「更新成功」のメッセージ表示と共に詳細画面(show.html.erb)へ画面遷移。
      # 「転送したいアクションへのURL→book_path(book.id)を指定」する事で、 showアクション、show.html.erb(詳細画面)へリダイレクトする。
    redirect_to book_path(@book.id)
   else
    # 更新に失敗した場合の処理(エラーメッセージが表示される)。エラー情報を持つ変数@bookについてはノータッチ。誤って再定義しないように。
    render :edit
   end
  end

  # ビュー側で実装する「削除」ボタンをクリックすると、削除リストのid付きでURLが送信される。
  # 送られてきた削除idを元にレコードが探され、そのレコードを削除する。
  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to '/books'
  end
  # private…一種の境界線。「ここから下のコードは、このcontroller(books_controller.rb)の中でしか呼び出せません」という意味。(×他ファイル)
  private
  # ストロングパラメータというフォームから入力されたデータを受け取る仕組み(「アプリケーションを完成させよう」2章の後半参照)。脆弱性対策。
  # モデル名_params…メソッド名。(今回はbook_params)このメソッドをここに書く理由については、2章の後半(メソッドの呼び出しに制限をかける)参照。
  # ーーーーーーーーーーーーparams…フォームから送られてくるデータが入っている。ーーーーーーーーーーーー
  # require…送られてきたデータの中からモデル名(ここでは:book)を指定し、データを絞り込む。(モデル名での絞り込みであってtitleやbodyといったカラムの指定、絞り込みはしてない)
  # permit…require(モデル名の条件)で絞り込んだデータの中から、取得や保存を許可するカラムを指定する。
  # requireやpermitでモデル名やカラムの指定、絞り込みをするのは、「悪意あるユーザーが改竄したデータを保存しないようにする」為。
  def book_params
    params.require(:book).permit(:title, :body, :user_id)
  end
end
