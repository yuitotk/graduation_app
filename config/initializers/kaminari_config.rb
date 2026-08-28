# ページネーション（一覧を件数で区切って表示する）用Gem「Kaminari」の設定
Kaminari.configure do |config|
  # 1ページあたりに表示する件数のデフォルト値
  config.default_per_page = 10
end
