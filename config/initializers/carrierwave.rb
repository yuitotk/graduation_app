# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  config.cache_storage = :file

  if Rails.env.production?
    # Cloudinaryの設定だけ読み込む（storageはここで切り替えない）
    Cloudinary.config_from_url(ENV.fetch("CLOUDINARY_URL"))
  end
end
