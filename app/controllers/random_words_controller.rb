class RandomWordsController < ApplicationController
  before_action :require_login

  def pick
    if RandomWord.count < 2
      @message = "辞書ワードが2件未満です。seedを追加してください。"
      @words = []
    else
      @words = RandomWord.order(Arel.sql("RAND()")).limit(2)
    end
  end
end
