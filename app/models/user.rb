class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Userモデルに、bookモデルとの1:Nの関係を実装。
  has_many :books, dependent: :destroy
  # 画像の表示・投稿機能の実装コード。ActiveStorageを使って画像を表示・投稿する際は、どのモデルに対して画像を使うのかを宣言する必要がある。
  # 今回は、Userモデルに画像をつけたいので、このapp/models/user.rbに設定する。
  # Userモデルに、プロフ画像を扱うためのprofile_imageカラムが追記されたかのように扱えるようになる(他のカラムと同様にprofile_imageも扱えるようになる)
  # PostImageモデルと同様、ActiveStorage(ファイルアップロードを簡単に行える機能,gem)を使い画像をアップロードできるようにする。
  # profile_imageという名前でActiveStorageでユーザーごとのプロフィール画像を保存できるように設定。
  has_one_attached :profile_image
  # バリデーションの設定。←モデルのファイルに設定内容を記述する。
  # validatesで「必須入力」にしたい項目を指定し、入力されたデータのpresence（存在）をチェックする。
  # trueと記述すると、データが存在しなければならないという設定になる。
  # 一意性を持たせ、かつ2～20文字の範囲で設定している。
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }, uniqueness: true
  # presence: trueは設定してはならない。サインアップやログイン時にintroductionを入力しないと、新規登録やログイン出来なくなってしまう。
  # 自己紹介文は最大50文字までに設定している。
  validates :introduction, length: { maximum: 50 }
  # get_profile_imageというメソッドを作成。これはアクションとは少し違い、特定の処理を名前で呼び出すことができるようになる。
  # Userモデルの中に記述することで、カラムを呼び出すようにこの処理（メソッド）を呼び出すことができるようになる。
  # このメソッドの内容は、画像が設定されていない場合はapp/assets/imagesに格納されているsample-author1.jpgという画像をデフォルト画像として、
  # ActiveStorage(ファイルアップロードを簡単に行える機能,gem)に格納して表示するというもの。
  def get_profile_image(width, height)
    # image.attached?=>imageに対して.attached?という中身のデータ(今回は画像)が存在するかを確認するメソッド呼び出し。
    # attached?は、画像が存在していればtrue、存在していなければfalseを返す。(条件文のunless文になってるのはこれが理由)
    unless profile_image.attached?
      # 以下は真偽値が偽の場合に行われる処理。
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'no_image.jpg', content_type: 'image/jpeg')
    end
      # 画像サイズの変更を行っている。画像の縦横サイズを渡された引数(width,height)のサイズに変換。
      profile_image.variant(resize_to_limit: [width, height]).processed
  end
end
