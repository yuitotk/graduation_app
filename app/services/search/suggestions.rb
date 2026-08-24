module Search
  # rubocop:disable Metrics/ClassLength
  class Suggestions
    VALID_SCOPES = %w[all home story event element story_event_idea].freeze
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

    # 検索対象はタイトル・メモ両方。候補として画面に出す文字列自体は title のみ
    # 返り値: { home: [{ title:, matched_by_memo: }, ...], story: [...], ... }
    # matched_by_memo は、タイトル自体は一致せず、メモの中身だけで見つかった場合に true
    # scopeが特定なら、そのカテゴリだけ返す
    def call
      return {} if @q.blank?

      case @scope
      when "home"             then { home: build_home }
      when "story"            then { story: build_story }
      when "event"            then { event: build_event }
      when "element"          then { element: build_element }
      when "story_event_idea" then { story_event_idea: build_story_event_idea }
      else
        {
          home: build_home,
          story: build_story,
          event: build_event,
          element: build_element,
          story_event_idea: build_story_event_idea
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

    # タイトルだけでなくメモの中身も検索対象にする。
    # 候補として画面に出す文字列自体は、あくまでタイトル(select_titles参照)。
    def apply_text_search(rel)
      like = "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"
      rel.where("ideas.title LIKE :q OR ideas.memo LIKE :q", q: like)
    end

    def apply_story_element_filter(rel)
      return rel if @story_element_id.blank?

      rel.joins(idea_placement: :idea_placement_elements)
         .where(idea_placement_elements: { story_element_id: @story_element_id })
         .distinct
    end

    def select_titles(rel)
      titles =
        rel.group("ideas.title")
           .order(Arel.sql("MAX(ideas.created_at) DESC"))
           .limit(LIMIT)
           .pluck("ideas.title")

      return [] if titles.empty?

      title_matched_set = titles_matching_query_itself(titles)

      titles.map do |title|
        { title: title, matched_by_memo: title_matched_set.exclude?(title) }
      end
    end

    # 渡されたタイトル群のうち、タイトル自体にも検索ワードが含まれるものだけを返す。
    # (これに含まれないタイトルは、メモの中身だけで見つかったということになる)
    def titles_matching_query_itself(titles)
      like = "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"

      base_ideas
        .where(title: titles)
        .where("title LIKE :q", q: like)
        .distinct
        .pluck(:title)
        .to_set
    end

    def build_home
      return [] if @story_id.present?
      return [] if @story_element_id.present?

      rel =
        apply_text_search(base_ideas)
        .where.missing(:idea_placement)

      select_titles(rel)
    end

    def build_story
      rel =
        apply_text_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "Story" })

      rel = rel.where(idea_placements: { placeable_id: @story_id }) if @story_id.present?
      rel = apply_story_element_filter(rel)
      select_titles(rel)
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
      select_titles(rel)
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
      select_titles(rel)
    end

    def build_story_event_idea
      rel =
        apply_text_search(base_ideas)
        .joins(:idea_placement)
        .where(idea_placements: { placeable_type: "StoryEventIdea" })

      if @story_id.present?
        rel = rel.joins("INNER JOIN story_event_ideas ON story_event_ideas.id = idea_placements.placeable_id")
                 .joins("INNER JOIN story_events ON story_events.id = story_event_ideas.story_event_id")
                 .where(story_events: { story_id: @story_id })
      end

      rel = apply_story_element_filter(rel)
      select_titles(rel)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
