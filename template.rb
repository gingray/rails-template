relative_path = File.dirname(__FILE__)
administrate = ask('use administrate y/n?').downcase == 'y'
devise = ask('use devise y/n?').downcase == 'y'
webpacker = ask('use webpacker y/n?').downcase == 'y'

hash = { administrate: administrate, devise: devise, webpacker: webpacker }
remove_file 'Gemfile'
remove_file '.ruby-version'

template File.join(relative_path, 'ruby-version.tt'), '.ruby-version'
template File.join(relative_path, "Gemfile.tt"), "Gemfile", hash
after_bundle do
  remove_dir "test"
end

application do <<-RUBY
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.view_specs false
      g.helper_specs false
    end
RUBY
end
run 'spring stop'
generate 'rspec:install'
remove_file '.rspec'
copy_file File.join(relative_path, '.rspec'), '.rspec'
copy_file File.join(relative_path, '.env.example'), '.env.example'
copy_file File.join(relative_path, '.rubocop.yml'), '.rubocop.yml'

insert_into_file 'spec/spec_helper.rb', before: 'RSpec.configure do |config|' do
  <<~RUBY
  require 'vcr'
  RUBY
end

insert_into_file 'config/application.rb', after: "RSpec.configure do |config|\n" do
  <<~RUBY
  config.include FactoryBot::Syntax::Methods
  RUBY
end


insert_into_file 'spec/spec_helper.rb' do
  <<~RUBY
    VCR.configure do |config|
      config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
      config.hook_into :faraday
      config.configure_rspec_metadata!
      config.default_cassette_options = { record: :new_episodes }
    end
  RUBY
end

insert_into_file 'config/application.rb', after: "require 'rails/all'\n" do
  <<~RUBY
  require 'dotenv/rails-now'
  RUBY
end

insert_into_file 'config/application.rb', after: "Bundler.require(*Rails.groups)\n" do
  <<~RUBY
  Dotenv::Railtie.load
  RUBY
end

copy_file File.join(relative_path, 'database.yml'), 'config/database.yml'


