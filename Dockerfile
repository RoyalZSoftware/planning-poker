FROM ruby:2.6.10-alpine3.15

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle

COPY .

ENTRYPOINT ["ruby", "web/app.rb"]

EXPOSE 4568

