module StoriesHelper
  # "- [x] 〜〜" の行だけ抜き出す（未チェックは拾わない）
  def checked_checklist_items(text)
    text.to_s.lines.filter_map do |line|
      m = line.match(/^\s*-\s*\[[xX]\]\s*(.+)\s*$/)
      m ? m[1].strip : nil
    end
  end
end
