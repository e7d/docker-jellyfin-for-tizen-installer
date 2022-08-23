FROM ubuntu:22.04 AS tizen-studio
# Install Tizen Studio dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y sudo curl pciutils zip
# Prepare Tizen user
RUN useradd -m -d /opt/tizen -G sudo tizen
RUN echo "tizen ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/tizen
# Switch to Tizen user
USER tizen
WORKDIR /opt/tizen
# Install Tyzen Studio
RUN curl https://download.tizen.org/sdk/Installer/tizen-studio_4.6/web-cli_Tizen_Studio_4.6_ubuntu-64.bin -o /tmp/web-cli_Tizen_Studio_4.6_ubuntu-64.bin \
    && chmod +x /tmp/web-cli_Tizen_Studio_4.6_ubuntu-64.bin \
    && ulimit -n 10000 \
    && /tmp/web-cli_Tizen_Studio_4.6_ubuntu-64.bin --accept-license /opt/tizen/tizen-studio \
    && rm -rf /tmp/web-cli_Tizen_Studio_4.6_ubuntu-64.bin

FROM ubuntu:22.04 AS jellyfin-tizen
# Install Jellyfin for Tizen dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y sudo curl git
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo bash \
    && sudo apt-get install -y nodejs yarn \
    && sudo npm install -g npm
# Copy Tizen Studio dependencies
COPY --from=tizen-studio /opt/tizen/tizen-studio/sdk.info /opt/tizen/tizen-studio/sdk.info
COPY --from=tizen-studio /opt/tizen/tizen-studio/jdk /opt/tizen/tizen-studio/jdk
COPY --from=tizen-studio /opt/tizen/tizen-studio/tools /opt/tizen/tizen-studio/tools
# Prepare Jellyfin Web
RUN cd /opt \
    && git clone https://github.com/jellyfin/jellyfin-web.git \
    && cd jellyfin-web \
    && npm ci --no-audit
# Build Jellyfin for Tizen
RUN cd /opt \
    && git clone https://github.com/jellyfin/jellyfin-tizen.git \
    && cd jellyfin-tizen \
    && ulimit -n 10000 \
    && JELLYFIN_WEB_DIR=../jellyfin-web/dist npm ci --no-audit \
    && /opt/tizen/tizen-studio/tools/ide/bin/tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock" \
    && /opt/tizen/tizen-studio/tools/ide/bin/tizen package -t wgt -o . -- .buildResult

FROM ubuntu:22.04 AS jellyfin-tizen-installer
# Copy Tizen Studio dependencies
COPY --from=tizen-studio /opt/tizen/tizen-studio/sdk.info /opt/tizen/tizen-studio/sdk.info
COPY --from=tizen-studio /opt/tizen/tizen-studio/jdk /opt/tizen/tizen-studio/jdk
COPY --from=tizen-studio /opt/tizen/tizen-studio/tools /opt/tizen/tizen-studio/tools
# Copy Jellyfin for Tizen build
COPY --from=jellyfin-tizen /opt/jellyfin-tizen/Jellyfin.wgt /opt/Jellyfin.wgt
# Copy entrypoint executable
COPY resources/jellyfin-for-tizen-installer.sh /jellyfin-for-tizen-installer.sh
# Set-up entrypoint
ENTRYPOINT [ "/jellyfin-for-tizen-installer.sh" ]
