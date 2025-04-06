FROM ruby:3.2.8

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  yarn \
  postgresql-client \
  build-essential \
  libpq-dev \
  libvips \
  make \
  g++

# Set working directory
WORKDIR /app

# Copy app source
COPY . .

# Install Ruby and JavaScript dependencies
RUN gem install bundler -v 2.1.4
RUN bundle install
RUN yarn install

# Precompile Rails + React assets
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# Cloud Run requires exposing port 8080
EXPOSE 8080

# Start Rails with Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

