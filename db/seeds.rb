# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

noun_words = %w[
  勇者 魔王 竜 錬金術 学園 王国 砂漠 海賊 魔法 遺跡 予言 呪い
  剣 盾 弓 短剣 槍 斧 杖 聖剣 魔剣 王子 王女 皇帝 皇后 姫 騎士
  魔導士 僧侶 盗賊 精霊 妖精 悪魔 天使 魔物 亡霊 吸血鬼 人形 使者
  守護者 追放者 裏切り者 生贄 鍵 本 地図 宝石 秘薬 仮面 冠 玉座 神殿
  城塞 迷宮 洞窟 森 湖 炎 氷 雷 影 光 星 月 太陽 夜明け 黄昏 嵐 霧 雪
  花 血 契約 秘密 記憶 運命 宿命 真実 嘘 願い 復讐 希望 絶望 革命 伝説
  神話 旋律 沈黙 夢 幻 門 祭壇 砂時計 鏡 指輪 首飾り 紋章 羽根 黒猫 白狼
  列車 船 廃都 塔 村 都 城 禁書 呪文 結界 予兆 遺物 秘宝 財宝 断章
  楽園 深淵 奈落 王座 玉座 街道 古城 地下墓地 牢獄 沼 聖堂 書庫 温泉 港
  城門 荒野 谷 河川 橋 舞台 劇場 酒場 市場 工房 学者 研究者 発明家 将軍
  兵士 国境 盟約 密使 手紙 楽譜 日記 石板 宝箱 鐘 火山 雨雲 稲妻 雫
  竜鱗 王冠 聖杯 亡国 魔石 聖印 秘文 血筋 一族 部族 里 禁域 異界 魔界
  天界 精神 時間 空間 偶像 告白 噂 野望 執念 祝福 加護 災厄 試練 使命
  因果 気配 鼓動 静寂 余白 絆 旅路 航路 迷子 片翼 隻眼 義手 義足 孤島
]

verb_words = %w[
  戦う 守る 奪う 逃げる 召喚する 裏切る 滅ぼす 封印する 探す 蘇る
  救う 失う 隠す 暴く 砕く 焼く 凍らせる 貫く 切り裂く 導く 拒む 祈る
  誓う 呪う 目覚める 沈む 浮かぶ 消える 現れる 超える 従う 逆らう 奪い返す
  操る 支配する 解く 解き放つ 見つける 追う 追い詰める 逃がす 呼び覚ます
  眠らせる 汚す 清める 結ぶ 断つ 開く 閉ざす 捧げる 受け継ぐ 見守る 疑う
  信じる 叶える 壊す 創る つなぐ 引き裂く 選ぶ 覚える 忘れる 取り戻す
  守り抜く 乗り越える 侵す 抗う 潜む 漂う 踏み込む 盗む 暴走する 変身する
  復活する 崩れる 融ける 歪む 響く ささやく 誘う 告げる 覚醒する 契る 染まる
  狂う 試す 率いる 見下ろす かばう 破る 叫ぶ 嘆く 微笑む 泣く 笑う 見抜く
  語る 隠れる 近づく 離れる 集う 散る 伏せる 走る 跳ぶ 滑る 落ちる 登る
  渡る ひらく 満ちる 枯れる 震える 灯す 揺れる ほどく 編む 刻む 拡がる 沈める
  解読する 記す 読み解く 見届ける 乗せる 運ぶ 抱く 手放す 研ぐ 磨く 編み出す
  書き換える ねじ曲げる 覆す 打ち砕く かき消す すり抜ける 付き従う 呼ぶ 招く
  さえぎる かき乱す 奮い立つ 覚ます 見失う 抱え込む 解明する 掘り起こす 隠し通す
  言い放つ 受け入れる 退ける 退く 誘い込む 見張る 付きまとう ほどこす 見染める
  突き放す 揺さぶる 交わす 突き進む 見上げる 見据える ひざまずく ひるがえる
]

noun_words.each do |w|
  random_word = RandomWord.find_or_initialize_by(word: w)
  random_word.part_of_speech = :noun
  random_word.save!
end

verb_words.each do |w|
  random_word = RandomWord.find_or_initialize_by(word: w)
  random_word.part_of_speech = :verb
  random_word.save!
end
