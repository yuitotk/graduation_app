class TopsController < ApplicationController
  def top
    redirect_to ideas_path if logged_in?
  end
end
