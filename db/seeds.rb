print 'Cleaning Data if exists...'

Game.destroy_all
Product.destroy_all
SystemRequirement.destroy_all
Category.destroy_all
User.destroy_all

puts 'Ok'.green

print 'Creating Users...'
User.create!(name: 'User 1', email: 'user1@email.com', password: '123456')
User.create!(name: 'User 2', email: 'user2@email.com', password: '123456')
User.create!(name: 'User 3', email: 'user3@email.com', password: '123456')
User.create!(name: 'João', email: 'joaoramires.engsoft@gmail.com', password: '123456')
User.create!(name: 'Lucas', email: 'lucasmoura@ioasys.com.br', password: '123456')
puts 'Ok'.green

print 'Creating Sytem Requirements...'
system_requirements = []
system_requirements << SystemRequirement.create!(
  name: 'Basic',
  processor: 'AMD Ryzen 3',
  video_board: 'NVidia Geforce 1060',
  memory: '8GB',
  operational_system: "Windows 10",
  storage: '500GB'
)
system_requirements << SystemRequirement.create!(
  name: 'Intermediate',
  processor: 'AMD Ryzen 5',
  video_board: 'NVidia Geforce 1080',
  memory: '16GB',
  operational_system: "Windows 10",
  storage: '1TB'
)
system_requirements << SystemRequirement.create!(
  name: 'Advanced',
  processor: 'AMD Ryzen 7',
  video_board: 'NVidia Geforce 2080',
  memory: '16GB',
  operational_system: "Windows 10",
  storage: '1TB'
)
puts 'Ok'.green

print 'Creating Categories...'
categories = []
15.times do
  categories << Category.create!(name: Faker::Game.unique.genre)
end
puts 'Ok'.green

print 'Creating Games...'
30.times do
  game_name = Faker::Game.unique.title
  availability = %i[available unavailable].sample
  categories_count = rand(0..3)
  game_categories_ids = []
  featured = [true, false].sample
  release_date = (0..15).to_a.sample.days.ago
  categories_count.times { game_categories_ids << Category.all.sample.id }
  game = Game.create!(
    mode: %i[pvp pve both].sample,
    release_date: release_date,
    developer: Faker::Company.name,
    system_requirement: system_requirements.sample
  )
  Product.create!(
    name: game_name,
    description: Faker::Lorem.paragraph,
    price: Faker::Commerce.price(range: 50.0..300.0),
    status: availability,
    featured: featured,
    category_ids: game_categories_ids,
    productable: game,
    image_url: "https://imgur.com/rENbpgq"
  )
end
puts 'Ok'.green

print 'Creating Licenses...'
Game.all.each do |game|
  50.times do |i|
    status = %i[available in_use inactive].sample
    platform = %i[steam epic].sample
    License.create!(
      key: Digest::MD5.hexdigest("#{game.product.name} #{i}"),
      status: status,
      platform: platform,
      game: game
    )
  end
end
puts 'Ok'.green
puts 'Done.'.green
