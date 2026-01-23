# "#################################################"
# Dockerfile to build a GitHub Pages Jekyll site
#   - Ubuntu 24.04
#   - Ruby 3.3.4
#   - Node.js & npm (for potential future Lunr.js search)
#   - Jekyll 3.10.0
#   - GitHub Pages 232
#
#   Based on: https://gist.github.com/BillRaymond/db761d6b53dc4a237b095819d33c7332#file-post-run-txt
#   Modified to include Node.js/npm and proper WORKDIR
#
# Instructions:
#  1. Build: docker build -t field-guide-jekyll .
#  2. Run: docker run --rm -it -v "$(pwd):/srv/jekyll" -p 4000:4000 field-guide-jekyll bundle exec jekyll serve
# "#################################################"
FROM ubuntu:24.04

# "#################################################"
# "Get the latest APT packages and security updates"
# "apt-get update"
RUN apt-get update && apt-get upgrade -y

# "#################################################"
# "Install Ubuntu prerequisites for Ruby and GitHub Pages (Jekyll)"
# "Partially based on https://gist.github.com/jhonnymoreira/777555ea809fd2f7c2ddf71540090526"
RUN apt-get -y install git \
    curl \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm6 \
    libgdbm-dev \
    libdb-dev \
    apt-utils \
    nodejs \
    npm

# "#################################################"
# "GitHub Pages/Jekyll is based on Ruby. Set the version and path"
# "As of this writing, use Ruby 3.3.4 to match GitHub Pages"
# "Based on: https://talk.jekyllrb.com/t/liquid-4-0-3-tainted/7946/12"
ENV RBENV_ROOT=/usr/local/src/rbenv
ENV RUBY_VERSION=3.3.4
ENV PATH=${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH

# "#################################################"
# "Install rbenv to manage Ruby versions"
RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
  && git clone https://github.com/rbenv/ruby-build.git \
    ${RBENV_ROOT}/plugins/ruby-build \
  && ${RBENV_ROOT}/plugins/ruby-build/install.sh \
  && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

# "#################################################"
# "Install ruby and set the global version"
RUN rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION}

# "#################################################"
# Install program to configure locales
RUN apt-get install -y locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen

# Set default locale for the environment
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# "#################################################"
# "Install the version of Jekyll that GitHub Pages supports"
# "Based on: https://pages.github.com/versions/"
# "Note: If you always want the latest 3.9.x version,"
# "       use this line instead:"
# "       RUN gem install jekyll -v '~>3.9'"
RUN gem update bundler
RUN gem install jekyll -v '3.10.0'
RUN gem install github-pages -v '232'

# "#################################################"
# "Set the working directory for Jekyll projects"
WORKDIR /srv/jekyll

# Expose Jekyll's default port and LiveReload port
EXPOSE 4000 35729
