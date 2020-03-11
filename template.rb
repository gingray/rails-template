relative_path = File.dirname(__FILE__)
administrate = ask('use administrate y/n?').downcase == 'y'
devise = ask('use devise y/n?').downcase == 'y'

hash = { administrate: administrate, devise: devise }
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
insert_into_file 'spec/spec_helper.rb' do
  <<~RUBY
    VCR.configure do |config|
      config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
      config.hook_into :faraday
    end
  RUBY
end

