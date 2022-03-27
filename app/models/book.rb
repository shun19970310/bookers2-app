class Book < ApplicationRecord
  # バリデーションの設定。←モデルのファイルに設定内容を記述する。
  # validatesで「必須入力」にしたい項目を指定し、入力されたデータのpresence（存在）をチェックする。
  # trueと記述すると、データが存在しなければならないという設定になる。
  belongs_to :user
  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }
end
