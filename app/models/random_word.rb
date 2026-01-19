class RandomWord < ApplicationRecord
  validates :word, presence: true, uniqueness: true
end
