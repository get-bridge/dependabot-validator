FROM ruby:3.1-alpine
ENV GITHUB_WORKSPACE=/usr/src/app

WORKDIR $GITHUB_WORKSPACE

COPY Gemfile $GITHUB_WORKSPACE
COPY Gemfile.lock $GITHUB_WORKSPACE

RUN bundle -j $(nproc)

COPY main.rb $GITHUB_WORKSPACE
COPY lib     $GITHUB_WORKSPACE/lib
# TODO: remove spec/ from final version
COPY spec    $GITHUB_WORKSPACE/spec

entrypoint ["/usr/src/app/main.rb"]
