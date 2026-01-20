require "test_helper"

class AiGenerationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get ai_generations_create_url
    assert_response :success
  end
end
