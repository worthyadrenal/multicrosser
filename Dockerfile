FROM ruby:3.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  yarn \
  postgresql-client \
  build-essential \
  libpq-dev \
  libvips

# Set the working directory
WORKDIR /app

# Copy app code
COPY . .

# Install Ruby and JS dependencies
RUN gem install bundler
RUN bundle install
RUN yarn install

# Precompile assets for production
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# Cloud Run expects port 8080
EXPOSE 8080

# Start the server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
