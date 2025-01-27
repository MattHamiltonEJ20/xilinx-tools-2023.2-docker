FROM ubuntu:noble-20240429
ENV DEBIAN_FRONTEND=noninteractive

# Configure local Ubuntu mirror as package source
RUN \
  sed -i -re 's|http://archive.ubuntu.com/ubuntu|http://mirror.aarnet.edu.au/pub/ubuntu|g' /etc/apt/sources.list

# Install base system utilities
RUN \
  ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    libncurses6 \
    locales \
    lsb-release \
    net-tools \
    patch \
    pigz \
    unzip \
    wget && \
  apt-get autoclean && \
  apt-get autoremove && \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && \
  rm -rf /var/lib/apt/lists/*

# Install additional utilities
RUN \
  apt-get update -y && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-pip \
    python3-yaml \
    vim-tiny \
    yq && \
  pip3 install --break-system-packages pyyaml && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*

# Install Ubuntu desktop and XRDP there is prbably a better way to do the user name and password here
RUN \
  apt update && DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop xrdp && \
  useradd -m matt -p $(openssl passwd password) && usermod -aG sudo matt && \
  adduser xrdp ssl-cert && \
  sed -i '3 a echo "\
  export GNOME_SHELL_SESSION_MODE=Lubuntu\\n\
  export XDG_SESSION_TYPE=x11\\n\
  export XDG_CURRENT_DESKTOP=Lubuntu:GNOME\\n\
  export XDG_CONFIG_DIRS=/etc/xdg/xdg-Lubuntu:/etc/xdg\\n\
  " > ~/.xsessionrc' /etc/xrdp/startwm.sh

# # Install compatibility libraries for Vivado
# RUN \
#   if [ "$(lsb_release --short --release)" = "22.04" ]; then \
#     wget -q -P /tmp http://linux.mirrors.es.net/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb && \
#     dpkg-deb --fsys-tarfile /tmp/libssl1.*.deb | \
#       tar -C /tools/Xilinx/Vivado/${VIVADO_VERSION}/lib/lnx64.o/Ubuntu/22 --strip-components=4 -xavf - ./usr/lib/x86_64-linux-gnu/ && \
#     rm /tmp/libssl1.*.deb ; \
#   fi

# Set up Vivado version and installer details
ENV VIVADO_VERSION=2023.2
ARG VIVADO_INSTALLER="FPGAs_AdaptiveSoCs_Unified_${VIVADO_VERSION}_1013_2256.tar.gz"
ARG VIVADO_UPDATE="Vivado_Vitis_Update_2023.2.2_0209_0950.tar.gz"
ARG VIVADO_INSTALLER_CONFIG="/vivado-installer/install_config_vivado.${VIVADO_VERSION}.txt"

# Copy Vivado installer files and install Vivado
COPY vivado-installer/ /vivado-installer/
RUN \
  mkdir -p /vivado-installer/install && \
  if [ -e /vivado-installer/$VIVADO_INSTALLER ]; then \
    pigz -dc /vivado-installer/$VIVADO_INSTALLER | tar xa --strip-components=1 -C /vivado-installer/install ; \
  else \
    echo "Error: Vivado installer file $VIVADO_INSTALLER not found in /vivado-installer." >&2 && exit 1 ; \
  fi && \
  if [ ! -e ${VIVADO_INSTALLER_CONFIG} ]; then \
    /vivado-installer/install/xsetup \
      -p 'Vivado' \
      -e 'Vivado ML Enterprise' \
      -b ConfigGen && \
    echo "No installer configuration file was provided. Generating a default one for you to modify." && \
    echo "-------------" && \
    cat /root/.Xilinx/install_config.txt && \
    echo "-------------" && \
    exit 1 ; \
  fi ; \
  /vivado-installer/install/xsetup \
    --agree 3rdPartyEULA,XilinxEULA \
    --batch Install \
    --config ${VIVADO_INSTALLER_CONFIG} && \
  rm -r /vivado-installer/install

# Handle optional Vivado update if provided
RUN \
  if [ -n "$VIVADO_UPDATE" ]; then \
    mkdir -p /vivado-installer/update && \
    if [ -e /vivado-installer/$VIVADO_UPDATE ]; then \
      pigz -dc /vivado-installer/$VIVADO_UPDATE | tar xa --strip-components=1 -C /vivado-installer/update ; \
    else \
      echo "Error: Vivado update file $VIVADO_UPDATE not found in /vivado-installer." >&2 && exit 1 ; \
    fi && \
    /vivado-installer/update/xsetup \
      --agree 3rdPartyEULA,XilinxEULA \
      --batch Update \
      --config ${VIVADO_INSTALLER_CONFIG} && \
    rm -r /vivado-installer/update ; \
  fi && \
  rm -rf /vivado-installer

# Expose RDP port and set entry point
EXPOSE 3389

# Set up the container to pre-source the Vivado environment
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD service dbus start; /usr/lib/systemd/systemd-logind & service xrdp start ; bash;
