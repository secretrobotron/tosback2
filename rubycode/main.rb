require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'mechanize' # will probably need to use this instead to handle sites that require session info

Dir["lib/*.rb"].each {|file| require file }

$rules_path = "../rule_test/" # Directories should include trailing slash
$results_path = "../crawl/"
$reviewed_crawl_path = "../crawl_reviewed/"
$log_dir = "../logs/"
$error_log = "errors.log"
$run_log = "run.log"
$modified_log = "modified.log"
$empty_log = "empty.log"
$notifier = TOSBackNotifier.instance

if ARGV.length == 0
  TOSBackApp.log_stuff("Beginning script!",$run_log)
  
  tba = TOSBackApp.new($rules_path)
  
  tba.run_app
    
  TOSBackApp.log_stuff("Script finished! Check #{$error_log} for rules to fix :)",$run_log)

  TOSBackApp.git_modified

elsif ARGV[0] == "-empty"
  
  TOSBackApp.find_empty_crawls($results_path,512)

else
  filecontent = File.open(ARGV[0])
  ngxml = Nokogiri::XML(filecontent)
  filecontent.close

  site = ngxml.xpath("//sitename[1]/@name").to_s
  
  docs = []
  
  ngxml.xpath("//sitename/docname").each do |doc|
    docs << TOSBackDoc.new({site: site, name: doc.at_xpath("./@name").to_s, url: doc.at_xpath("./url/@name").to_s, xpath: doc.at_xpath("./url/@xpath").to_s, reviewed: doc.at_xpath("./url/@reviewed").to_s})
  end
  
  docs.each do |doc|
    doc.scrape
    doc.write
  end
end