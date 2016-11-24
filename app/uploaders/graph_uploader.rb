class GraphUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    'graphs'
  end
end
