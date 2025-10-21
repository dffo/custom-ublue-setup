#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 
dnf5 install -y vim
dnf5 install -y fastfetch
dnf5 install -y featherpad
dnf5 install -y rclone
dnf5 install -y dconf-editor
dnf5 install -y racket
dnf5 install -y xwayland-satellite
dnf5 install -y gh
dnf5 install -y pipx
dnf5 install -y samba
dnf5 install -y docker
dnf5 install -y distrobox
dnf5 install -y btop
dnf5 install -y stow
dnf5 install -y tldr
# caja has live timestamp updating and thunar doesn't :(
dnf5 install -y caja

dnf5 install -y mate-polkit

dnf5 install -y virt-manager
dnf5 install -y qemu-kvm
dnf5 install -y qemu
dnf5 install -y libvirt

cat > /etc/polkit-1/rules.d/80-libvirt-manage.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&
        subject.local &&
        subject.active &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF

dnf5 install -y ddcutil

cat > /etc/udev/rules.d/45-ddc-i2c.rules << 'EOF'
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF

dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 group install -y multimedia
dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
dnf5 update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

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
