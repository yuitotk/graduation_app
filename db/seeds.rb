# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

%w[勇者 魔王 竜 錬金術 学園 王国 砂漠 海賊 魔法 遺跡 予言 呪い].each do |w|
  RandomWord.find_or_create_by!(word: w)
end
