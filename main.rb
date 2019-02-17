# Script was developed and worked on Windows.
# There are unresolved problems with the Curb library on Windows.
# So OpenURI module was used instead.
require 'open-uri'
require 'nokogiri'
require 'csv'

def humanize secs
    [[60, :seconds], [60, :minutes], [24, :hours], [Float::INFINITY, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
  
        "#{n.to_i} #{name}" unless n.to_i==0
      end
    }.compact.reverse.join(' ')
end

print "\nPlease enter a category link:\n"
url = gets.chomp.to_s

print "\nPlease enter the name of the resulting CSV file (with .csv extension):\n"
csvFileName = gets.chomp.to_s

timeStart = Time.now

print "\nGetting category page with all products...\t"

html = open(url)
doc = Nokogiri::HTML(html)

showallForm = doc.xpath("//form[@class='showall']")

unless showallForm.empty?
    showallFormUrl = "#{showallForm.xpath("@action")}?"

    showallForm.xpath("div//input").each do |param|
        showallFormUrl << "#{param.xpath("@name")}=#{param.xpath("@value")}&"
    end

    showallFormUrl.chomp('&')

    html = open(showallFormUrl)
    doc = Nokogiri::HTML(html)
end

print "OK\n"
print "Getting products...\t"

products = []
doc.xpath("//a[@class='product-name']").each do |product|
    products.push(
        name: product.xpath("@title").to_s,
        url: product.xpath("@href").to_s
    )
end

print "OK\n"

CSV.open(csvFileName, "w", force_quotes: true) do |csv|
    csv << ["Name", "Price", "Image"]

    print "Parsing products pages...\n"

    total = 0
    products.each do |product|
        print "\tParsing \"#{product[:name]}\" page...\t"

        html = open(product[:url])
        doc = Nokogiri::HTML(html)
        
        doc.xpath("//div[@id='attributes']//fieldset//div//ul//li").each do |li|
            total += 1
            csv << [
                "#{product[:name]} - #{li.xpath("label//span[@class='radio_label']").inner_text}",
                li.xpath("label//span[@class='price_comb']").inner_text,
                doc.xpath("//img[@id='bigpic']//@src").to_s
            ]
        end

        print "OK\n"
    end

    print "\nAll products were parsed and were saved in #{csvFileName}\n"
    print "Total number of products is #{total}\n"
end

print "\nScript completed in #{humanize(Time.now - timeStart)}\n\n"
