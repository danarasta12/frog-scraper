require "nokogiri"
require "httparty"
require "csv"

# target page
response = HTTParty.get("https://www.lavillarose.fr/nos-voitures/", {

  headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"},

})

# store the collected data
Voiture = Struct.new(:image, :url, :name)

# scraping logic
doc = Nokogiri::HTML(response.body)

# initialize the list of objects that will store all retrieved data

voitures = []

# select all voiture HTML elements
voiture_cards = doc.css(".div-liste-voiture")

# iterate over the HTML cards
voiture_cards.each do |voiture_card|

    # extract the data of interest

    image = voiture_card.at_css(".oxy-carousel-builder_gallery-image img").attribute("src").value

    url = voiture_card.at_css(".div-liste-infos-voitures").attribute("href").value

    name = voiture_card.at_css(".div-titre-annee-voiture h2").text

    # instantiate an Voiture object with the collected data

    voiture = Voiture.new(url, image, name)

    # add the Voiture instance to the array of scraped objects

    voitures.push(voiture)

end

# populate the CSV output file

CSV.open("output.csv", "wb") do |csv|

  # write the CSV header

  csv << ["url", "image", "name"]

  # transfrom each voiture scraped info to a CSV record

  voitures.each do |voiture|

    csv << voiture

  end

end
