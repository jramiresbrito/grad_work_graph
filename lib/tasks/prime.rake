if Rails.env.development? || Rails.env.test?
  require 'factory_bot'

  namespace :dev do
    desc 'Sample data for local development environment'
    task prime: 'db:setup' do
      include FactoryBot::Syntax::Methods

      print "Creating Users..."
      create(:user, name: "User 1", email: "user1@email.com")
      create(:user, name: "User 2", email: "user2@email.com")
      create(:user, name: "User 3", email: "user3@email.com")
      15.times do
        create(:user)
      end
      puts "Ok".green

      print "Creating Sytem Requirements..."
      system_requirements = []
      %w[Basic Intermediate Advanced].each do |sr_name|
        system_requirements << create(:system_requirement, name: sr_name)
      end
      puts "Ok".green

      print "Creating Categories..."
      categories = []
      25.times do
        categories << create(:category, name: Faker::Game.unique.genre)
      end
      puts "Ok".green

      print "Creating Games..."
      30.times do
        game_name = Faker::Game.unique.title
        availability = %i[available unavailable].sample
        categories_count = rand(0..3)
        game_categories_ids = []
        featured = [true, false].sample
        release_date = (0..15).to_a.sample.days.ago
        categories_count.times { game_categories_ids << Category.all.sample.id }
        game = create(:game, system_requirement: system_requirements.sample, release_date: release_date)
        create(:product, name: game_name, status: availability,
                         featured: featured, category_ids: game_categories_ids, productable: game)
      end
      puts "Ok".green

      print "Creating Licenses..."
      50.times do
        game = Game.all[0...5].sample
        status = %i[available in_use inactive].sample
        platform = %i[steam epic].sample
        create(:license, status: status, platform: platform, game: game)
      end
      puts "Ok".green
      puts "Done.".green
    end
  end
end
