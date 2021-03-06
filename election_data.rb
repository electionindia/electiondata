#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'optparse'

OptionParser.new do |o|
  o.on('--scrape') { |b| $scrape = b }
  o.on('--parse') {|b| $parse = b}
  o.on('--buildjson') {|b| $buildjson = b}
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

  candidates = []
  candidate_lines = `grep "javascript:__doPostBack(" #{f}`
  if candidate_lines
    candidate_lines.split("\n").each{|l|
      tds = /<td>(\d*)<\/td><td><a.*>(.*)<\/a><\/td><td>(.*)<\/td>/.match l
      info = {
        name: tds[2],
        party: tds[3],
        state: state,
        constituency: constituency,
        data: {}
      }
      candidates.push info
    }
  end

  return {
    state: state,
    constituency: constituency,
    candidates: candidates
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

if $parse
  data = []
  File.open("scraped_filelist", "r") {|f| data.concat f.read.split("\n")}
  if !data.length
    puts "Cannot find scraped files list."
    exit
  end
  puts "----Parsing----"
  parsed_info = []
  data.each {|f|
    r = parse_file f
    if !r
      puts "  X Unable to parse #{f}"
    else
      puts "  > #{r[:state]}, #{r[:constituency]}"
      parsed_info.push r
    end
  }

  File.open("parsed_info.json", "w+"){|f|
    f.write parsed_info.to_json.to_s
  }
end

if $buildjson
  puts "----Building json----"
  File.open("parsed_info.json", "r"){|f|
    parsed_info = JSON.parse(f.read)
  }

  constituencies = {}
  cons_candidates = {}

  parsed_info.each{ |p|
    constituencies[p["state"]] ||= []
    constituencies[p["state"]].push p["constituency"]

    cons_candidates[p["constituency"]] = {candidates:p["candidates"], state: p["state"]}

  }
  constituencies.each{|k,v|
    v = v.uniq!
  }
  puts "  > json/constituency.json -- state/constituency list"
  File.open("json/constituency.json", "w+"){|f|
    f.write JSON.pretty_generate(models:constituencies.map{|k,v| {k=>v}})
  }

  cons_candidates.each{|cons, info|
    lower_state = info[:state].downcase.gsub(/\s+/,"-").gsub(/[^a-z-]/,"")
    lower_cons = cons.downcase.gsub(/\s+/,"-").gsub(/[^a-z-]/,"")
    `mkdir -p json/#{lower_state}`
    puts "  > json/#{lower_state}/#{lower_cons}.json"
    File.open("json/#{lower_state}/#{lower_cons}.json", "w+"){|f|
      f.write JSON.pretty_generate(model: info[:candidates])
    }

  }


end


