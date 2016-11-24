require_relative '../dir_importer'

namespace :import do
  task dir: :environment do
    importer = DirImporter.new(ENV['DIR']).run
    CreateGraphsService.new(importer.import).call
  end
end
