class RandomWord < ApplicationRecord
  enum :part_of_speech, { noun: 0, verb: 1 }

  validates :word, presence: true, uniqueness: true
  validates :part_of_speech, presence: true
end
