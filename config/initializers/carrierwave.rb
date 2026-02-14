# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  config.cache_storage = :file

  if Rails.env.production?
    config.storage = :cloudinary
    Cloudinary.config_from_url(ENV.fetch("CLOUDINARY_URL"))
  else
    config.storage = :file
  end
end
