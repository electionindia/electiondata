#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'optparse'

OptionParser.new do |o|
  o.on('--scrape') { |b| $scrape = b }
  o.on('--parse') {|b| $parse = b}
  o.on('-h') { puts o; exit }
  o.parse!
end

def parse_file f
  state_line = `cat #{f} | grep 'STATE NAME'`
  els = (/<b>(.*)<\/b>/.match state_line)[1].split("-")
  if els.length == 1
    return nil
  else
    state = els[1,5].join("-").strip
  end

  constituency_line = `cat #{f} | grep 'PC NAME'`
  els = (/<b>(.*)<\/b>/.match constituency_line)[1].split("-")
  if els.length == 1
    return nil
  else
    constituency = els[1,5].join("-").strip
  end

  return {
    state: state,
    constituency: constituency
  }

end

if $scrape
  complete_file_list = []
  puts "----Scraping----"
  MAX_STATE = 28
  MAX_UNION = 7
  MAX_CONS = 100
  state_codes = Array (1..MAX_STATE).map{|i| "S#{'%02d' % i}" }
  state_codes.concat Array (1..MAX_UNION).map{|i| "U#{'%02d' % i}" }
  puts "Total states and union territories: #{state_codes.length}"
  state_codes.each { |s|
    puts "Area: #{s}"
    constituency_code = 1
    `mkdir -p area_#{s}`
    keep_scraping = true
    Array(1..MAX_CONS).each { |constituency_code|
      if keep_scraping
        scrapedfile = "area_#{s}/constituency_#{constituency_code}"
        cmd = "wget -q -O #{scrapedfile} 'http://affidavitarchive.nic.in/DynamicAffidavitDisplay/CANDIDATEAFFIDAVIT.aspx?YEARID=May-2014%20(%20GEN%20)&AC_No=#{constituency_code}&st_code=#{s}&constType=PC'"
        `#{cmd}`
        r = parse_file scrapedfile
        if r.nil?
          `rm -r #{scrapedfile}`
          keep_scraping = false
        else
          puts "  > #{r[:state]}, #{r[:constituency]}"
          complete_file_list.push scrapedfile
        end
      end
    }
  }
  File.open("scraped_filelist", "w+") {|f| f.write(complete_file_list.join("\n"))}
end


