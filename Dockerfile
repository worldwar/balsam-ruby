FROM ruby:2.4.1

RUN mkdir -p /var/app

WORKDIR /var/app

RUN gem install bundler

RUN wget https://github.com/worldwar/balsam-ruby/archive/v0.1.1.tar.gz -O balsam.tar.gz

RUN tar -xvzf balsam.tar.gz

RUN mv balsam-ruby-0.1.1 balsam-ruby

WORKDIR /var/app/balsam-ruby

RUN bundle install

ENTRYPOINT ["bundle", "exec", "balsam"]