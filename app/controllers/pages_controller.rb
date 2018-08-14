class PagesController < ApplicationController
  include HighVoltage::StaticPage

  skip_authorization_check

  layout :layout_for_page

  private

  def layout_for_page
    case params[:id]
    when 'home'
      'home'
    else
      'application'
    end
  end
end
