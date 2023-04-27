FROM ruby:2.6.10

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle

COPY . .

ENTRYPOINT ["ruby", "web/app.rb"]

EXPOSE 8000

