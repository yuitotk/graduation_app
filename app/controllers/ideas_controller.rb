class IdeasController < ApplicationController
  before_action :require_login

  def index
    # いまは表示できればOK（一覧取得は次IssueでもOK）
  end

  def new
  end

  def create
  end
end
