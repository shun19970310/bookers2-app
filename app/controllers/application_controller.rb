class ApplicationController < ActionController::Base
  # ログイン認証が成功していないと、topページ,aboutページ以外の画面(ログインと新規登録は除く)は表示できない仕様にする。
  # ログインしていない状態でトップページ以外へアクセスされた場合は、ログイン画面へリダイレクトするように設定。
  # ログイン認証が済んでいる場合には全てのページにアクセス可能。
  # before_actionメソッド内に定義したメソッド(:authenticate_user!)は、このコントローラが動作する前(アクションが実行される前)に実行される。
  # 今回の場合、app/controllers/application_controller.rbファイルに記述したので、全てのコントローラで最初にbefore_action内のメソッドが実行される。
  # authenticate_userメソッドは、devise側が用意しているメソッド。:authenticate_user!とすることによって、「ログイン認証されていなければ、
  # ログイン画面へリダイレクトする」機能を実装できます。
  # exceptは指定したアクションをbefore_actionの対象から外す。「top,aboutページのみログイン状態に関わらずアクセス可能」と今回は設定している。
  before_action :authenticate_user!,except: [:top, :about]
  # 初期状態のdeviseは、サインアップ、サインイン時に「email」と「パスワード」しか受け取ることを許可されていない。
  # 従って最初はnameを入力しても、データとして保存することは出来ない状態。その為こちらで指定したnameも保存できるよう、許可を与える必要がある。
  # これは以前学んだストロングパラメータと同様にControllerに保存許可メソッド(configure_permitted_parameters)を実装する事で実現出来る。
  # deviseのコントローラは直接修正できないため、deviseのストロングパラメータを編集,実装する場合は、全てのコントローラに対する処理を行える権限を持つ
  # ApplicationControllerに記述する必要がある。以下のように記述することで、devise利用の機能(ユーザ登録、ログイン認証等)が使われる前に
  # configure_permitted_parametersメソッドが実行され、nameデータの保存,操作が可能になる。
  before_action :configure_permitted_parameters, if: :devise_controller?
  # after_sign_in_path_for=>Deviseが用意しているメソッド。サインイン後にどこに遷移するかを設定している。
  # このメソッドはDeviseの初期設定ではroot_pathになっている。サインイン後にルートパスに遷移していたのはこれが原因。
  # 下記のような記述をすることで、初期設定を上書き可能。今回はユーザーの詳細画面(user_path)へ遷移するように設定。
  # ログイン画面、または新規登録画面からサインインした際、遷移先がTopページではなくshow.html.erb(user_path)になるようにしている。
  def after_sign_in_path_for(resource)
    user_path(current_user.id)
  end
　# 11〜17行目のbefore_action :configure_permitted_parameters, if: :devise_controller?の説明を読め。
  # configure_permitted_parametersメソッドでは、devise_parameter_sanitizer.permitメソッドを使うことで
  # ユーザー登録(:sign_up)の際に、ユーザー名(:email)の保存,操作を許可している。これはストロングパラメータと同様の機能。
  # ストロングパラメータ=>フォームから入力されたデータを受け取る仕組み(「アプリケーションを完成させよう」2章の後半参照)。脆弱性対策。
  # permit…(require(モデル名の条件)で絞り込んだ)データの中から取得や保存を許可するカラムを指定する。
  # requireやpermitでモデル名やカラムの指定、絞り込みをするのは、「悪意あるユーザーが改竄したデータを保存しないようにする」為。
  # privateは記述をしたコントローラ内でしか参照出来ない。protectedは他のコントローラからも参照することが出来る。
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
  end
end
