#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 
dnf5 install -y fastfetch
dnf5 install -y featherpad
dnf5 install -y rclone
dnf5 install -y dconf-editor
dnf5 install -y racket
dnf5 install -y xwayland-satellite
dnf5 install -y gh
dnf5 install -y pipx

dnf5 install -y virt-manager
dnf5 install -y qemu-kvm
dnf5 install -y qemu

#raco pkg install pollen #nah, doesn't work---tries to make .local in root

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
#
dnf5 -y copr enable marcelohdez/dim
sudo dnf install -y dim-screen
dnf5 -y copr disable marcelohdez/dim

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable libvirtd
