class Authentication < ApplicationRecord
  # ✅ どのuserが、どのSNS（provider）の、どのアカウント（uid）と連携しているかを表す
  belongs_to :user
end
