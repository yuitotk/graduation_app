class AiGeneration < ApplicationRecord
  # ✅ 「誰が、いつAI作成を使ったか」の記録。1回の使用につき1行。
  belongs_to :user
end
