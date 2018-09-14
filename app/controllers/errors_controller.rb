class ErrorsController < ApplicationController
  def bomb
    raise "boom!"
  end
end
