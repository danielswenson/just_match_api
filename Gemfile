# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.1'

gem 'rails', '5.1.1' # Ruby on Rails MVC framework

gem 'bootsnap', '~> 1.1', require: false # Optimize Rails boot time

# TEXT PROCESSING
gem 'kramdown', '~> 1.13' # Markdown <> HTML
gem 'rinku', '~> 2.0.2' # Autolink

# SERVER
gem 'lograge', '~> 0.5' # Less verbose Rails log in production
gem 'puma', '~> 3.9' # App server

# Analytics
gem 'ahoy_matey', '~> 1.6'

# STORAGE
gem 'aws-sdk', '~> 2.9' # Upload images to AWS S3
gem 'pg', '~> 0.21' # Use postgresql as the database for Active Record
gem 'redis-activesupport', '~> 5.0' # To use Redis as the cache store for rack-attack

# RACK MIDDLEWARE
gem 'rack-attack', '~> 5.0' # Throttle API usage
gem 'rack-cors', '~> 0.4', require: 'rack/cors' # Configure CORS
gem 'rack-timeout', '~> 0.4' # Kill requests that run for too long

# BACKGROUND JOBS
gem 'sidekiq', '< 6' # Background worker (Redis-backed)
gem 'sidekiq-statistic', git: 'https://github.com/davydovanton/sidekiq-statistic'

# MONITORING
gem 'airbrake', '~> 6.1' # Error catcher and reporter
gem 'skylight', '~> 1.3' # Performance monitoring

# DATABASE / MODELS
gem 'ancestry', '~> 3.0' # Organize records in a tree structure
gem 'kaminari', '~> 1.0' # Easy pagination

# JSON
gem 'active_model_serializers', '~> 0.10' # Serialize models to JSON
gem 'json_api_helpers', path: 'lib/json_api_helpers' # JSON API helpers

# IMAGES
gem 'paperclip', '~> 5.1' # Image handler

# SECURITY
gem 'bcrypt', '~> 3.1.11', require: true # Encrypt passwords
gem 'pundit', '~> 1.1' # Authorization policies

# ADMIN
gem 'active_admin_datetimepicker', '~> 0.3' # Datetime picker for activeadmin
gem 'active_admin_filters_visibility', git: 'https://github.com/activeadmin-plugins/active_admin_filters_visibility'
gem 'active_admin_scoped_collection_actions', git: 'https://github.com/activeadmin-plugins/active_admin_scoped_collection_actions'
gem 'active_admin_theme', '~> 1.0' # activeadmin theme
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin' # Admin interface
gem 'blazer', git: 'https://github.com/ankane/blazer' # '~> 1.7' # Explore data with SQL
gem 'chosen-rails', '~> 1.5' # Needed for autocomplete select input for activeadmin
gem 'inherited_resources', '~> 1.7' # activeadmin Rails 5
gem 'uglifier', '~> 3.2' # Needed for activeadmin assets compilation

gem 'arbetsformedlingen', '~> 0.1'

gem 'welcome_app', path: 'lib/welcome_app' # Interact with WelcomeApp!

# Invoices
gem 'frilans_finans_api', path: 'lib/frilans_finans_api' # Interact with Frilans Finans API

# NOTIFICATIONS
gem 'email_reply_parser', '~> 0.5' # Parse reply emails
gem 'mail', '~> 2.6', '>= 2.6.6' # General email functionality
gem 'twilio-ruby', '~> 4.13' # Send SMS notifications

# GEO/LOCALE/LANGUAGE UTILS
gem 'banktools-se', '~> 2.6' # Validate Swedish bank account
gem 'countries', '~> 2.0', require: 'countries/global' # Country data in various locales
gem 'geocoder', '~> 1.4' # Geocode resources
gem 'global_phone', '~> 1.0' # Format cell phone numbers
gem 'google-cloud-translate', '~> 0.23' # Translate with Google Translate API
gem 'i18n_data', '~> 0.7' # Language and country names in various languages
gem 'iban-tools', '~> 1.1' # Validate IBAN
gem 'mailcheck', git: 'https://github.com/mailcheck/mailcheck-ruby' # Email suggestions for common email spelling misstakes
gem 'personnummer', '~> 0.0.9' # Swedish "personummer" or "samordningsnummer"
gem 'rails-i18n', '~> 5.0' # Rails translations

# PERFORMANCE GEMS
gem 'fast_blank', '~> 1.0' # Re-implements #blank? in C
gem 'fast_xs', '~> 0.8' # Re-implements String#to_xs in C
gem 'yagni_json_encoder', '~> 1.0' # Make Rails use the OJ gem for JSON

# DOCS
gem 'apipie-rails', '~> 0.5' # Easy API documentation
gem 'maruku', '~> 0.7' # Needed for apipie-rails markdown support

# UTILS
gem 'faker', '~> 1.7' # Easily generate fake data (used for seeding dev/test/staging)
gem 'honey_format', '~> 0.2' # Simple CSV reading

# DEVELOPMENT/TEST/DOCS
group :development, :test, :docs do
  gem 'bullet', '~> 5.5'
  gem 'byebug', '~> 9.0'
  gem 'consistency_fail', '~> 0.3'
  gem 'dotenv-rails', '~> 2.2'
  gem 'factory_girl_rails', '~> 4.8'
  gem 'fog', '~> 1.40' # Cloud services gem, in production the aws-sdk gem is used
  gem 'immigrant', '~> 0.3'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec_junit_formatter', '~> 0.2'
  gem 'rubocop', '~> 0.49', require: false
end

group :development do
  gem 'annotate', '~> 2.7'
  gem 'better_errors', '~> 2.1'
  gem 'binding_of_caller', '~> 0.7'
  gem 'derailed_benchmarks', '~> 1.3'
  gem 'i18n-tasks', '~> 0.9.2'
  gem 'i18n_generators', '~> 2.1'
  gem 'letter_opener', '~> 1.4'
  gem 'listen', '~> 3.1'
  gem 'memory_profiler', '~> 0.9'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'stackprof', '~> 0.2'
  gem 'web-console', '~> 3.5'
end

group :test, :docs do
  gem 'codeclimate-test-reporter', '~> 1.0', require: false
  gem 'database_cleaner', '~> 1.6'
  gem 'fuubar', '~> 2.2'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'simplecov', '~> 0.13', require: false
  gem 'timecop', '~> 0.8'
  gem 'webmock', '~> 3.0'
end
