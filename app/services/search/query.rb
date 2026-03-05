# app/services/search/query.rb
module Search
  class Query
    VALID_SCOPES = %w[all home story event element].freeze

    # rubocop:disable Naming/MethodParameterName
    def initialize(q:, scope:, story_id:, story_element_id:, user:)
      @q                = q.to_s.strip
      @scope            = normalize_scope(scope)
      @story_id         = story_id.presence&.to_i
      @story_element_id = story_element_id.presence&.to_i
      @user             = user
    end
    # rubocop:enable Naming/MethodParameterName

    def call
      return {} if @q.blank? && @story_element_id.blank?

      case @scope
      when "home"    then { home: build_home }
      when "story"   then { story: build_story }
      when "event"   then { event: build_event }
      when "element" then { element: build_element }
      else
        {
          home: build_home,
          story: build_story,
          event: build_event,
          element: build_element
        }
      end
    end

    private

    def normalize_scope(scope)
      s = scope.to_s
      return "all" unless VALID_SCOPES.include?(s)

      s
    end

    def apply_text_search(rel)
      return rel if @q.blank?

      like = "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"
      rel.where("ideas.title LIKE :q OR ideas.memo LIKE :q", q: like)
    end

    def base_ideas
      Idea.where(user_id: @user.id)
    end

    def split_created_moved(rel)
      {
        created_here: rel.where(idea_placements: { created_here: true }),
        moved: rel.where(idea_placements: { created_here: false })
      }
    end

    def apply_story_element_filter(rel)
      return rel if @story_element_id.blank?

      rel.joins(idea_placement: :idea_placement_elements)
         .where(idea_placement_elements: { story_element_id: @story_element_id })
         .distinct
    end

    def build_home
      return empty_pair if @story_id.present?
      return empty_pair if @story_element_id.present?

      rel =
        apply_text_search(base_ideas)
        .where.missing(:idea_placement)
        .order(created_at: :desc)

      { created_here: rel, moved: Idea.none }
    end

    def build_story
      rel =
        apply_text_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "Story" })

      rel = rel.where(idea_placements: { placeable_id: @story_id }) if @story_id.present?
      rel = apply_story_element_filter(rel)
      rel = rel.order(created_at: :desc)

      split_created_moved(rel)
    end

    def build_event
      rel =
        apply_text_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "StoryEvent" })

      if @story_id.present?
        rel = rel.joins("INNER JOIN story_events ON story_events.id = idea_placements.placeable_id")
                 .where(story_events: { story_id: @story_id })
      end

      rel = apply_story_element_filter(rel)
      rel = rel.order(created_at: :desc)
      split_created_moved(rel)
    end

    def build_element
      rel =
        apply_text_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "StoryElement" })

      if @story_id.present?
        rel = rel.joins("INNER JOIN story_elements ON story_elements.id = idea_placements.placeable_id")
                 .where(story_elements: { story_id: @story_id })
      end

      rel = apply_story_element_filter(rel)
      rel = rel.order(created_at: :desc)
      split_created_moved(rel)
    end

    def empty_pair
      { created_here: Idea.none, moved: Idea.none }
    end
  end
end
