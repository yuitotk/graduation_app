class RandomWordsController < ApplicationController
  before_action :require_login

  def pick
    if RandomWord.count < 2
      @message = "辞書ワードが2件未満です。seedを追加してください。"
      @words = []
      return
    end

    random_sql =
      if ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
        "RAND()"
      else
        "RANDOM()"
      end

    @words = RandomWord.order(Arel.sql(random_sql)).limit(2)
  end
end
