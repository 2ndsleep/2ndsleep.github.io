FROM arm32v7/alpine
RUN apk upgrade --update
RUN apk add ruby-full ruby-dev
RUN apk add gcc g++ make linux-headers
RUN gem install jekyll bundler

WORKDIR /srv/jekyll
