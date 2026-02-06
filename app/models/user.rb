class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :ideas, dependent: :destroy
  has_many :inquiries, dependent: :destroy
end
