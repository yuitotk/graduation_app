# app/services/search/suggestions.rb
module Search
  class Suggestions
    VALID_SCOPES = %w[all home story event element].freeze
    LIMIT = 10

    # rubocop:disable Naming/MethodParameterName
    def initialize(q:, scope:, story_id:, story_element_id:, user:)
      @q                = q.to_s.strip
      @scope            = normalize_scope(scope)
      @story_id         = story_id.presence&.to_i
      @story_element_id = story_element_id.presence&.to_i
      @user             = user
    end
    # rubocop:enable Naming/MethodParameterName

    # 候補は title のみ
    # 返り値: { home: [...], story: [...], event: [...], element: [...] }
    # scopeが特定なら、そのカテゴリだけ返す
    def call
      return {} if @q.blank?

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

    def base_ideas
      Idea.where(user_id: @user.id)
    end

    # 候補：titleのみ
    def apply_title_search(rel)
      like = "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"
      rel.where("ideas.title LIKE :q", q: like)
    end

    def apply_story_element_filter(rel)
      return rel if @story_element_id.blank?

      rel.joins(idea_placement: :idea_placement_elements)
         .where(idea_placement_elements: { story_element_id: @story_element_id })
         .distinct
    end

    # MySQL対応：title重複を潰しつつ、最新順で返す
    def select_titles(rel)
      rel.group("ideas.title")
         .order(Arel.sql("MAX(ideas.created_at) DESC"))
         .limit(LIMIT)
         .pluck("ideas.title")
    end

    # ホーム未所属：idea_placement が無い
    # ※「この作品内」ON（= story_id指定）のときはホームは対象外なので空
    def build_home
      return [] if @story_id.present?
      return [] if @story_element_id.present?

      rel =
        apply_title_search(base_ideas)
        .where.missing(:idea_placement)

      select_titles(rel)
    end

    # ストーリー内：placeable_type=Story
    def build_story
      rel =
        apply_title_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "Story" })

      rel = rel.where(idea_placements: { placeable_id: @story_id }) if @story_id.present?
      rel = apply_story_element_filter(rel)
      select_titles(rel)
    end

    # イベント内：placeable_type=StoryEvent
    # 「この作品内」ONなら story_events.story_id で絞る
    def build_event
      rel =
        apply_title_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "StoryEvent" })

      if @story_id.present?
        rel = rel.joins("INNER JOIN story_events ON story_events.id = idea_placements.placeable_id")
                 .where(story_events: { story_id: @story_id })
      end

      rel = apply_story_element_filter(rel)
      select_titles(rel)
    end

    # 要素内：placeable_type=StoryElement
    # 「この作品内」ONなら story_elements.story_id で絞る
    def build_element
      rel =
        apply_title_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "StoryElement" })

      if @story_id.present?
        rel = rel.joins("INNER JOIN story_elements ON story_elements.id = idea_placements.placeable_id")
                 .where(story_elements: { story_id: @story_id })
      end

      rel = apply_story_element_filter(rel)
      select_titles(rel)
    end
  end
end
