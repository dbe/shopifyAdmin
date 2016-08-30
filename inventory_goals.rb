if !ARGV[0]
  puts "Error: First argument is required, report file path"
  exit(1)
end

require 'shopify_api'

API_KEY = ENV['SHOPIFY_ADMIN_API_KEY']
PASSWORD = ENV['SHOPIFY_ADMIN_PASSWORD']
SHOP_NAME = 'pandajuice'


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
    '6mg' => {'30mL' => 3, '60mL' => 1},
    '12mg' => {'30mL' => 0, '60mL' => 0},
    '18mg' => {'30mL' => 0, '60mL' => 0}
  }
}

shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"
ShopifyAPI::Base.site = shop_url

products = ShopifyAPI::Product.where(:product_type => 'Juice')
missing = []

products.each do |product|
  vendor = product.vendor

  product.variants.each do |variant|

    #Hack around the fact that there is no option 2 on OFE because we haven't added different sizes yet
    option2 = variant.option2 || '30mL'

    goal = inventory_goals[vendor][variant.option1][option2]

    if variant.inventory_quantity < goal
      puts "Product title: #{product.title}"
      puts "Vendor: #{vendor}"
      puts "Option 1: #{variant.option1}"
      puts "Option 2: #{option2}"
      puts "Goal: #{goal}"
      puts "Quantity: #{variant.inventory_quantity}"
      missing.append({:vendor => vendor, :title => product.title, :nic => variant.option1, :size => option2, :quantity => (goal - variant.inventory_quantity)})
    end
  end

end

#Write report
File.open(ARGV[0], 'a') do |file|
  
end
