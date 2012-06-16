IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 5000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:PROMPT_MODE] = :SIMPLE

require 'irb/completion'
require 'irb/ext/save-history'
require 'pp'

require 'rubygems' rescue nil
require 'wirble'

Wirble.init
Wirble.colorize
