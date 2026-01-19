require "test_helper"

class RandomWordsControllerTest < ActionDispatch::IntegrationTest
  test "should get pick" do
    get random_words_pick_url
    assert_response :success
  end
end
