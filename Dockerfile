FROM ruby:2.4.1-alpine

RUN apk add --update openssl

RUN apk add --update git

RUN apk add --update ruby-dev

RUN apk add --update build-base

RUN apk add --update postgresql-dev

RUN mkdir -p /var/app

WORKDIR /var/app

RUN gem install bundler

RUN wget https://github.com/worldwar/balsam-ruby/archive/v0.1.1.tar.gz -O balsam.tar.gz

RUN tar -xvzf balsam.tar.gz

RUN mv balsam-ruby-0.1.1 balsam-ruby

WORKDIR /var/app/balsam-ruby

RUN bundle install

ENTRYPOINT ["bundle", "exec", "balsam"]
~
~
