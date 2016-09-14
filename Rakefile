require 'shopify_api'

API_KEY = ENV['SHOPIFY_ADMIN_API_KEY']
PASSWORD = ENV['SHOPIFY_ADMIN_PASSWORD']
SHOP_NAME = 'pandajuice'

task :setup_api do
  puts "Setting up api"

  shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
  ShopifyAPI::Base.site = shop_url
end

task :inventory_goals, [:filename] => [:setup_api] do |t, args|
  if not args[:filename]
    fail("*****Filename is required for output file. Syntax 'rake inventory_goals[filename]'")
  end

  #TODO: Really hacky way to store goal inventory quantities. Should store these as meta attributes on the actual objects in the database
  inventory_goals = {
    'OFE' => {
      '0mg' => {'30mL' => 1},
      '3mg' => {'30mL' => 3},
      '6mg' => {'30mL' => 1}
    },
    'Vape Wild' => {
      '0mg' => {'30mL' => 3, '60mL' => 1},
      '3mg' => {'30mL' => 5, '60mL' => 3},
      '6mg' => {'30mL' => 3, '60mL' => 2},
      '12mg' => {'30mL' => 0, '60mL' => 0},
      '18mg' => {'30mL' => 0, '60mL' => 0}
    },
    'Aspire' => {
      '0mg' => {'15mL' => 0},
      '3mg' => {'15mL' => 0},
      '6mg' => {'15mL' => 0},
      '12mg' => {'15mL' => 0}
    }
  }


  products = ShopifyAPI::Product.where(:product_type => 'Juice')
  missing = {}

  products.each do |product|
    vendor = product.vendor

    product.variants.each do |variant|
      goal = inventory_goals[vendor][variant.option1][variant.option2]

      if variant.inventory_quantity < goal
        #puts "Product title: #{product.title}"
        #puts "Vendor: #{vendor}"
        #puts "Option 1: #{variant.option1}"
        #puts "Option 2: #{variant.option2}"
        #puts "Goal: #{goal}"
        #puts "Quantity: #{variant.inventory_quantity}"

        missing[vendor] = {} if !missing[vendor]
        missing[vendor][product.title] = [] if !missing[vendor][product.title]
        missing[vendor][product.title].append( {:nic => variant.option1, :size => variant.option2, :quantity => (goal - variant.inventory_quantity) } )
      end
    end

  end

  #Write report
  filename = args[:filename]
  File.open(filename, 'a') do |file|
    missing.each do |vendor, titles|
      file.write("#{vendor}:\n")

      titles.each do |title, line_items|
        file.write("\t#{title}\n")

        line_items.each do |line_item|
          file.write("\t\t#{line_item[:quantity]} #{line_item[:nic]}-#{line_item[:size]}\n")
        end

        file.write("\n")
      end
    end
  end

end

