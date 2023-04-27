FROM ruby:2.6.10

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle

COPY . .

ENTRYPOINT ["sh", "start.sh"]

EXPOSE 8000

