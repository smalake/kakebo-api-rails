FROM ruby:3.2.2
ENV TZ Asia/Tokyo
ENV API_ROOT /kakebo-api

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim

RUN mkdir $API_ROOT
WORKDIR $API_ROOT

COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler
RUN bundle install

COPY build/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY . $API_ROOT

EXPOSE 8080
# CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]