FROM archlinux/archlinux:base

# Run setup script
COPY continuous-integration/setup.sh .
RUN ./setup.sh

# Additional packages needed for deployment
RUN pacman -Syu --noconfirm --needed git openssh
 
# Add user for deployment
ARG UID=1000
RUN useradd -ms /bin/bash --uid $UID deploymentuser
USER deploymentuser

# Copy entire build context into the container
COPY . /home/deploymentuser/zivid-arch-linux-pkgbuild-generator

# Set workdir to repo root
WORKDIR /home/deploymentuser/zivid-arch-linux-pkgbuild-generator