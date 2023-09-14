FROM ruby:3.2.2
ENV TZ Asia/Tokyo

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim

RUN mkdir /kakebo-api
WORKDIR /kakebo-api

COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler
RUN bundle install

COPY build/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY . /kakebo-api

EXPOSE 8000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8000"]