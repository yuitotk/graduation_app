# frozen_string_literal: true

namespace :users do
  desc "見本ストーリー一式(要素・イベント・詳細メモ・アイデア)を、まだ持っていない既存ユーザーに追加する"
  task seed_sample_content: :environment do
    # ✅ 見本ストーリー(is_sample: true)を1件も持っていないユーザーだけが対象。
    #    すでに実行済みの人には何もしないので、間違って複数回実行しても重複しない。
    target_users = User.where.not(id: Story.where(is_sample: true).select(:user_id))

    puts "対象ユーザー数: #{target_users.count}"

    seeded_count = 0
    failed_user_ids = []

    target_users.find_each do |user|
      Users::SampleContentSeeder.call(user)
      seeded_count += 1
      puts "seeded: user_id=#{user.id}"
    rescue StandardError => e
      failed_user_ids << user.id
      puts "failed: user_id=#{user.id} (#{e.class}: #{e.message})"
    end

    puts "完了: #{seeded_count}件作成"
    puts "失敗: #{failed_user_ids.join(', ')}" if failed_user_ids.any?
  end
end
