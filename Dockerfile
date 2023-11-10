FROM arm32v7/ruby
RUN gem install jekyll bundler
WORKDIR /srv/jekyll
