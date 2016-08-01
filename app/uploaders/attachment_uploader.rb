require 'fastimage'

class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb, :if => :image? do
    process resize_to_fit: [200, 200]
  end

  def image?(new_file)
    image_type = FastImage.type(get_file(new_file))
    image_type && image_type_whitelist.include?(image_type)
  end

  protected


  def image_type_whitelist
    %i(jpeg png gif)
  end

  def get_file(file)
    if file.is_a?(CarrierWave::SanitizedFile)
      return file.file
    end

    file
  end

end
