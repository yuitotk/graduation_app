class ApplicationController < ActionController::Base
  helper_method :current_search_story, :search_in_story?, :current_search_story_id

  private

  def current_search_story
    return @story if defined?(@story) && @story.present?
    return @story_event.story if defined?(@story_event) && @story_event.present?
    return @story_element.story if defined?(@story_element) && @story_element.present?

    sid = session[:search_story_id].presence
    return nil if sid.blank?

    current_user.stories.find_by(id: sid)
  end

  def current_search_story_id
    current_search_story&.id
  end

  def search_in_story?
    return false unless session[:search_in_story] == true
    return false if current_search_story_id.nil?

    session[:search_story_id].to_i == current_search_story_id
  end

  def not_authenticated
    redirect_to login_path, alert: "ログインしてください"
  end
end
