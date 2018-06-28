def get_remote(src, dest = nil)
  dest ||= src
  repo = 'https://raw.github.com/ttexan1/rails_template/master/files/'
  remote_file = repo + src
  remove_file dest
  get(remote_file, dest)
end

# アプリ名の取得
@app_name = app_name

# gitignore
get_remote('gitignore', '.gitignore')

# Gemfile
get_remote('Gemfile')

# Database
if yes?('use PostgreSQL?(y/n)')
  gsub_file 'Gemfile', /^gem\s\'sqlite3\'/, 'gem \'pg\''
  get_remote('config/database.yml.example', 'config/database.yml')
  gsub_file "config/database.yml", /myapp/, @app_name
end

# install gems
run 'bundle install --path vendor/bundle --jobs=4'

# create db
run 'bundle exec rails db:create'

# annotate gem
run 'rails g annotate:install'

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    # 日本語化
    I18n.available_locales = [:en, :ja]
    I18n.enforce_available_locales = true
    # libファイルの自動読み込み
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  }
end

# For Bullet (N+1 Problem)
insert_into_file 'config/environments/development.rb',%(
  config.after_initialize do
    Bullet.enable = true # Bulletプラグインを有効
    Bullet.alert = true # JavaScriptでの通知
    Bullet.bullet_logger = true # log/bullet.logへの出力
    Bullet.console = true # ブラウザのコンソールログに記録
    Bullet.rails_logger = true # Railsログに出力
  end
), after: 'config.assets.debug = true'

# jqueryの追加とturbolinksの削除
inject_into_file 'app/assets/javascripts/application.js', after: "//= require rails-ujs\n" do "//= require jquery\n" end
gsub_file 'app/assets/javascripts/application.js', /\/\/=\srequire\sturbolinks\n/, ''

# Bootstrap
remove_file 'app/assets/stylesheets/application.css'
get_remote('app/assets/stylesheets/application.scss')
get_remote('app/assets/stylesheets/bootstrap-custom.scss')
get_remote('app/assets/stylesheets/reset.scss')

# Simple Form
generate 'simple_form:install --bootstrap'

# Kaminari config
generate 'kaminari:config'


# git
git
git :init
git add: '.'
git commit: "-a -m 'rails new #{@app_name} -m https://raw.githubusercontent.com/ttexan1/rails_template/master/template.rb'"
