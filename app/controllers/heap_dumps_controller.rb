class HeapDumpsController < ApplicationController
  before_action :set_heap_dump

  def show
    @space_objects =
      @heap_dump.space_objects.group(:generation)
        .select('generation, SUM(bytesize) AS bytesize, SUM(memsize) AS memsize, COUNT(*) AS total')
  end

  def generation # rubocop:disable Metrics/MethodLength
    @limit = params[:limit].presence || 50
    @generation = params[:gen]
    @space_objects = @heap_dump.space_objects.where(generation: @generation)

    @allocations =
      @space_objects.group(:file, :line).limit(@limit).order('SUM(memsize) DESC')
        .select('SUM(memsize) AS memsize, file, line')

    @object_counts =
      @space_objects.group(:file, :line).limit(@limit).order('COUNT(*) DESC')
        .select('COUNT(*) AS total, file, line')

    @type_counts =
      @space_objects.group(:type, :file, :line).limit(@limit).order('COUNT(*) DESC')
        .select('COUNT(*) AS total, type, file, line')

    @ref_counts =
      @space_objects.joins(:references)
        .group(:file, :line).limit(@limit)
        .select('COUNT(*) AS total, file, line').order('COUNT(*) DESC')

    @duplicate_string =
      @space_objects.where(type: 'STRING'.freeze).where.not(value: nil)
        .group(:value, :file, :line).limit(@limit)
        .select('COUNT(*) AS total, value, file, line').order('COUNT(*) DESC')
  end

  protected

  def set_heap_dump
    @heap_dump = HeapDump.find(params[:id])
  end
end
