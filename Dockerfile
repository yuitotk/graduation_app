FROM ruby:3.1.4

WORKDIR /app

# rails new と mysql2 のために必要なもの
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      default-mysql-client \
      default-libmysqlclient-dev \
      nodejs \
      npm && \
    npm install -g yarn && \
    gem update --system && \
    gem install bundler && \
    gem install rails -v 7.0.4.3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
