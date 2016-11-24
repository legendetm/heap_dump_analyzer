class CreateGraphsService
  TYPES = %w(type-mem type-count string-count string-mem data-count data-mem).freeze

  attr_reader :import

  def initialize(import)
    @import = import
  end

  def call
    CreateGraphService::TYPES.each do |type|
      CreateGraphService.new(import, type: type).call
    end
  end
end
