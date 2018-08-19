def get_remote(src, dest = nil)
 dest ||= src
 repo = '/Users/{your_directory}/rails_template/files/' # TODO: この行を正しいディレクトリで実行or編集
 remote_file = repo + src
 remove_file dest
 get(remote_file, dest)
end

@app_name = app_name

get_remote('gitignore', '.gitignore')
get_remote('Gemfile')

# if yes?('use PostgreSQL?(y/n)')
#   gsub_file 'Gemfile', /^gem\s\'sqlite3\'/, 'gem \'pg\''
#   get_remote('config/database.yml.example', 'config/database.yml')
#   gsub_file "config/database.yml", /myapp/, @app_name
# end

run 'bundle install --path vendor/bundle --jobs=4'
run 'bundle exec rails db:create'
run 'rails g annotate:install'
application  do
 %q{
   config.time_zone = 'Tokyo'
   config.active_record.default_timezone = :local
   config.generators do |g|
     g.orm :active_record
     g.assets false
     g.helper false
   end
   I18n.available_locales = [:en, :ja]
   I18n.enforce_available_locales = true
   config.autoload_paths += %W(#{config.root}/lib)
   config.autoload_paths += Dir["#{config.root}/lib/**/"]
 }
end
insert_into_file 'config/environments/development.rb',%(
 config.after_initialize do
   Bullet.enable = true
   Bullet.alert = true
   Bullet.bullet_logger = true
   Bullet.console = true
   Bullet.rails_logger = true
 end
), after: 'config.assets.debug = true'

inject_into_file 'app/assets/javascripts/application.js', after: "//= require rails-ujs\n" do "//= require jquery\n" end
gsub_file 'app/assets/javascripts/application.js', /\/\/=\srequire\sturbolinks\n/, ''
remove_file 'app/assets/stylesheets/application.css'
get_remote('app/assets/stylesheets/application.scss')
get_remote('app/assets/stylesheets/bootstrap-custom.scss')
get_remote('app/assets/stylesheets/reset.scss')
generate 'simple_form:install --bootstrap'
generate 'kaminari:config'
