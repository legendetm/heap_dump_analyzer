class WelcomeController < ApplicationController
  def index
    @imports = Import.recent
  end
end
