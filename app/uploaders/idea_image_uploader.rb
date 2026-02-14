class IdeaImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def extension_allowlist
    %w[jpg jpeg png webp]
  end

  def size_range
    1..(5.megabytes)
  end
end
