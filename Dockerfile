FROM ubuntu
MAINTAINER Brandur <brandur@mutelight.org>

RUN apt-get update
#RUN apt-get upgrade -y
RUN apt-get -y install build-essential curl git-core
RUN apt-get -y install zlib1g-dev libcurl4-openssl-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev libpq-dev
RUN apt-get clean

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rbenv/bin:/usr/local/rbenv/shims:/opt/nginx/sbin

# rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
#RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/bash.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /etc/bash.bashrc
ENV RBENV_ROOT /usr/local/rbenv

# ruby-build
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN PREFIX=/usr/local /usr/local/rbenv/plugins/ruby-build/install.sh

# ruby
RUN /bin/bash -l -c 'rbenv install 2.1.1'
RUN /bin/bash -l -c 'rbenv global 2.1.1'

# nginx
RUN gem install bundler passenger
RUN rbenv rehash
RUN passenger-install-nginx-module --auto-download --auto --prefix=/usr/local/nginx --languages ruby
#ADD extra/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
ADD extra/init/nginx.conf /etc/init/nginx.conf
VOLUME /var/log/nginx

# app
ADD . /app
WORKDIR /app
RUN bundle install

EXPOSE 80
EXPOSE 443

CMD /bin/bash
