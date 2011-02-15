#!/usr/bin/ruby

require 'rubygems'
require 'sys/proctable'
include Sys

TIOCSTI=0x00005412

curr_tty = %x{tty}
puts "current tty is #{curr_tty}"
curr_tty = curr_tty.to_s.strip

def get_tty_from_fd fd
  index = fd.uniq.rindex{|item| item =~ /^\/dev\/pts\/\d+/}
  fd[index] unless index.nil?
end

username = Etc.getlogin 
command = ARGV[0]
ttys = []

ProcTable.ps do |pt|
  if pt.environ['USER'] == username && pt.tty_nr != 0
    if pt.environ['SSH_TTY'] #using the environ is easier here, but it doesn't always exist.
      process_tty = pt.environ['SSH_TTY']
    else
      process_tty = get_tty_from_fd(pt.fd.values)
    end
    ttys << process_tty.to_s.strip
  end
end

ttys.uniq.each do | tty_name |
  puts "#{tty_name} in loop"
  unless tty_name == curr_tty # want to filter out the current terminal, and perhaps run the command there last
    File.open(tty_name,'w') do | f |
      puts "Running #{command} on #{tty_name}"
      command.chars do | char |
        #f.ioctl(TIOCSTI,char) #commented for testing
      end
      #f.ioctl(TIOCSTI,"\n") #commented for testing
    end
  end
end
