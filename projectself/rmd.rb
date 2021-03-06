#! /usr/local/bin/ruby
# /root/ruby-1.6.7/sha.rb
# Created: Feb 24,2003 Monday 13:42:33
# Author: tcshacina
# $Id: sha.rb,v 1.3 2003/02/24 16:37:57 root Exp $
# usage: ruby sha.rb [file]
# hint: ruby-list 11775 11780

require 'digest/rmd160'

RMD160 = Digest::RMD160

class String
  def rmdhex
    RMD160.new(self).hexdigest
  end
end

# close したいだけ close しなくてもいいかな
# File.open(filename).read で代用化
def fileread(file)
  f = File.open(file)
  str = f.read
  f.close
  str
end

def usage
  STDERR.puts "usage: #{$0} [OPTION] [FILE]...
  -t, -v      check SHA256 sums against given list
      --status     do not output anything, status code shows success"
  exit 1
end

opt_check = false
opt_status = false

while ARGV[0] =~ /^-/
  $_ = ARGV.shift
  if ~/^-c/ or ~/^--check/
    opt_check = true
  elsif ~/^--status/
    opt_status = true
  else
    usage
  end
end

if opt_status == true and opt_check == false
  STDERR.puts "#{$0}: the --status option is meaningful only when verifying checksums(--check)"
  exit 1
end

#require 'sha2'

if opt_check
  ck_count_total = 0
  ck_count_failed = 0
end

while file_str = gets(nil)
  if opt_check
    file_str.split("\n").each do |l|
      ck_count_total += 1
      sum1, fname = l.split
      sum2 = fileread(fname).shahex
      status = if sum1 == sum2
                 'OK'
               else
                 ck_count_failed += 1
                 'FAILED'
               end
      if opt_status
      else
        puts fname + ': ' + status
      end
    end
  else
    puts file_str.rmdhex + '  ' + ARGF.filename
  end
end

if opt_check and ck_count_failed > 0
  if opt_status
  else
    STDERR.puts "#{$0}: WARNING: #{ck_count_failed} of #{ck_count_total} computed checksum did NOT match"
  end
  exit 1
end