#!/usr/bin/ruby
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

IRB.conf[:PROMPT_MODE] = :SIMPLE

%w[rubygems ap looksee/shortcuts wirble bond interactive_editor].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

if defined?(Bond)
  Bond.start
end

if defined?(AwesomePrint)
IRB::Irb.class_eval do
  def output_value
    ap @context.last_value
  end
end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
end

def copy_history
  copy history
end

def paste
  `pbpaste`
end

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']
