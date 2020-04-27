# Base image is [JAremko/alpine-vim/alpine-vim-base](https://github.com/JAremko/alpine-vim/blob/master/alpine-vim-base/Dockerfile)
FROM alpine:latest as builder

MAINTAINER ryoo14 <anana12185@gmail.com>

WORKDIR /tmp

# Install dependencies
RUN apk add --no-cache \
    build-base \
    ctags \
    git \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    make \
    ncurses-dev \
    bash \
    python3 \
    python3-dev

# Build vim
RUN git clone --depth 1 https://github.com/vim/vim \
 && cd vim \
 && ./configure \
    --disable-gui \
    --disable-netbeans \
    --enable-terminal \
    --enable-multibyte \
    --enable-python3interp \
    --with-features=big \
    --with-python-config-dir=/usr/lib/python2.7/config \
 && make install
 
# Build fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf \
 && bash \
 && cd /root/.fzf \
 && ./install --all

# Install dotfiles
RUN git clone --depth 1 https://github.com/ryoo14/dotfiles.git /root/dotfiles \
 && cd /root \
 && ln -s dotfiles/.vimrc .vimrc \
 && ln -s dotfiles/.vim .vim \
 && ln -s dotfiles/.gemrc .gemrc \
 && ln -fs dotfiles/.bashrc .bashrc \
 && ln -fs dotfiles/.fzf.bash .fzf.bash \
 && ln -s dotfiles/.ctags .ctags


FROM alpine:latest

COPY --from=builder /usr/local/bin/ /usr/local/bin
COPY --from=builder /usr/local/share/vim/ /usr/local/share/vim/
COPY --from=builder /root /root
COPY dein_script /root

# ENV RUBY_VERSION 2.6.5
# ENV GO_VERSION 1.13.4

RUN apk update && apk upgrade \ 
# vim
 && apk add --no-cache \
    autoconf \
    bash \
    bison \
    build-base \
    bzip2 \
    bzip2-dev \
    ca-certificates \
    coreutils \
    ctags \
    curl \
    diffutils \
    gcc \
    gdbm-dev \
    git \
    glib-dev \
    libc-dev \
    libffi-dev \
    libice \
    libsm \
    libx11 \
    libxml2-dev \
    libxslt-dev \
    libxt \
    linux-headers \
    make \
    ncurses \
    ncurses-dev \
    openssl-dev \
    procps \
    readline-dev \
    ruby-dev \
    the_silver_searcher \
    yaml-dev \
    zlib-dev \
    go \
    ruby \
 && vim -s /root/plug_script \
# vim-lsp(Ruby)
 && gem install bundler solargraph json etc \ 
 && apk add ruby-irb \
# vim-lsp(Go)
 && GO111MODULE=on go get golang.org/x/tools/gopls@latest
## ruby
# && git clone --depth 1 https://github.com/rbenv/rbenv.git ~/.rbenv \
# && git clone --depth 1 https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
# && $HOME/.rbenv/bin/rbenv install $RUBY_VERSION \
# && $HOME/.rbenv/bin/rbenv global $RUBY_VERSION

ENV PATH /root/go/bin:$PATH

ENTRYPOINT ["vim"]
