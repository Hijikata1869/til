require 'date'
require "tty-prompt"

prompt = TTY::Prompt.new

print '今日の学習内容：'

input = gets.chomp

today = Date.today

old_file = File.read('./learning_log.md')

new_file = "# #{today.year}/#{today.month}/#{today.day}\n#{input}\n" + "\n#{old_file}"

File.open('./learning_log.md', 'w') do |f|
  f.puts new_file
end

`git add learning_log.md`

commit_content = `git diff HEAD learning_log.md`

confirmation_message = <<~TEXT
  ----------------------------------------
  #{commit_content}
  ----------------------------------------
  \nこの内容でcommitします。よろしいですか？\n\n
TEXT

is_commit = prompt.yes?("#{confirmation_message}")

if is_commit
  `git commit -m "updated learning_log.md"`
  puts "\ncommitしました\n\n"
else
  puts 'commitできませんでした'
end

is_push = prompt.yes?("続けてpushしますか?")

if is_push
  `git push origin main`
  puts "\npushしました\n\n"
else
  puts 'pushできませんでした'
end