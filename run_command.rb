#!/usr/bin/ruby

require 'rubygems'
require 'sys/proctable'
include Sys

TIOCSTI=0x00005412

curr_tty = %x{tty}
puts "current tty is #{curr_tty}"

def get_tty fd
  index = fd.uniq.rindex{|item| item =~ /^\/dev\/pts\/\d+/}
  fd[index] unless index.nil?
end

username = Etc.getlogin 
command = ARGV[0]
ttys = []

ProcTable.ps do |pt|
  if pt.environ['USERNAME'] == username && pt.tty_nr != 0
    ttys << get_tty(pt.fd.values)
  end
end

ttys.uniq.each do | tty_name |
  puts tty_name.class
  puts curr_tty.class
  unless tty_name == curr_tty
    File.open(tty_name,'w') do | f |
      puts "Running #{command} on #{tty_name}"
      command.chars do | char |
        #f.ioctl(TIOCSTI,char)
      end
      #f.ioctl(TIOCSTI,"\n")
    end
  end
end
