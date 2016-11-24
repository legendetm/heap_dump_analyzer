class ImportsController < ApplicationController
  before_action :set_import

  def show
    @heap_dumps = @import.heap_dumps
  end

  def diff
    @heap_dumps = @import.heap_dumps.order(time: :asc).where(id: param_ids)
    if @heap_dumps.size < 2
      flash.alert = 'Minimum 2 heap dumps must be selected!'
      redirect_to import_path(@import)
      return
    end

    @space_objects =
      SpaceObject.diff(@heap_dumps)
       .group(:type, :file, :line)
       .select('type, file, line, SUM(bytesize) AS bytesize, SUM(memsize) AS memsize, COUNT(1) as total')
       .order('COUNT(1) DESC')
  end

  private

  def set_import
    @import = Import.find(params[:id])
  end

  def param_ids
    Array(params[:ids]).compact
  end
end
