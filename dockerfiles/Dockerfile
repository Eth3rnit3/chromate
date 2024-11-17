FROM --platform=linux/amd64 ruby:3.2-slim

RUN apt-get update && apt-get install -y \
    nano \
    xvfb \
    curl \
    git \
    bash \
    build-essential \
    libx11-xcb1 \
    libxcomposite1 \
    libxrandr2 \
    libxdamage1 \
    libjpeg62-turbo \
    libwebp-dev \
    udev \
    fonts-freefont-ttf \
    fonts-noto-color-emoji \ 
    nodejs \
    npm \
    libxcursor1 \
    libgtk-3-0 \
    libpangocairo-1.0-0 \
    libcairo-gobject2 \
    libgdk-pixbuf2.0-0 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    gstreamer1.0-gl \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    libxslt1.1 \
    libwoff1 \
    libvpx7 \
    libevent-2.1-7 \
    libopus0 \
    libsecret-1-0 \
    libenchant-2-2 \
    libharfbuzz-icu0 \
    libhyphen0 \
    libmanette-0.2-0 \
    libflite1 \
    libavcodec-extra \
    libx11-dev \
    libxtst-dev \
    x11-utils \
    x11-apps \
    imagemagick \
    xdotool \
    fluxbox \
    ffmpeg \
    psmisc \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Préparer le système
RUN apt-get update && apt-get install -y wget gnupg2 lsb-release && rm -rf /var/lib/apt/lists/*

# Télécharger et ajouter la clé GPG
RUN wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg

# Ajouter le dépôt Google Chrome
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list

# Mise à jour et installation de Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable

ENV CHROME_BIN=/usr/bin/google-chrome

RUN gem install bundler -v 2.5.21

WORKDIR /chromate

COPY Gemfile Gemfile.lock chromate.gemspec ./
COPY lib/chromate/version.rb ./lib/chromate/version.rb

RUN bundle install

COPY dockerfiles/docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY . .

ENV DISPLAY=:99

WORKDIR /app

COPY docker_root/ /app/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD [ "bash" ]

# docker build -f dockerfiles/Dockerfile -t chromate .

# Run the container for testing chromate
# docker run -v $(pwd)/docker_root:/app -it chromate

# Run the container for development
# docker run -v $(pwd):/app -it chromate