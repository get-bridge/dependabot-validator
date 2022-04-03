FROM ruby:3.1-alpine
ENV APP_DIR=/usr/src/app

# TODO: remove spec/ from final version
COPY Gemfile \
  Gemfile.lock \
  main.rb \
  spec/ \
  /

RUN bundle -j $(nproc)

entrypoint ["/main.rb"]
