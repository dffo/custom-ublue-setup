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
dnf5 install -y docker docker-compose
dnf5 install -y distrobox
dnf5 install -y freerdp
dnf5 install -y btop
dnf5 install -y chezmoi
dnf5 install -y tldr
dnf5 install -y rsyslog

# Tell systemd to create the rsyslog directory
cat > /etc/tmpfiles.d/rsyslog.conf << 'EOF' 
d /var/lib/rsyslog 0755 root root - 
EOF

# persist journald entries
cat > /etc/tmpfiles.d/systemd-journal.conf << 'EOF'
d /var/log/journal 2755 root systemd-journal -
EOF

# Journald: forward to syslog
mkdir -p /etc/systemd/journald.conf.d/
cat > /etc/systemd/journald.conf.d/forward-to-syslog.conf << 'EOF'
[Journal]
ForwardToSyslog=yes
EOF


dnf5 install -y mate-polkit

dnf5 install -y virt-manager
dnf5 install -y qemu-kvm
dnf5 install -y qemu
dnf5 install -y libvirt
dnf5 install -y sshfs

dnf5 install -y terminus-fonts-console

# Set tty font to Terminus (for HiDPI)
cat > /etc/vconsole.conf << 'EOF'
KEYMAP="us"
FONT="ter-v32b"
EOF

# Give wheel permission to make virtual machines without passwd
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

# Disable hires scrolling
mkdir -p /etc/libinput
cat > /etc/libinput/local-overrides.quirks << 'EOF'
[disable hires scroll]
MatchName=*
AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES;
EOF

dnf5 install -y ddcutil

cat > /etc/udev/rules.d/45-ddc-i2c.rules << 'EOF'
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF

# Fix sddm scaling
cat > /etc/sddm.conf.d/99-scale.conf << 'EOF'
[General]
GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192
EOF

# Install nonfree codecs
dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 group install -y multimedia
dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
dnf5 update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# Install v4l2 loopback device
#dnf5 install -y kmod-v4l2loopback v4l2loopback-utils

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
#
dnf5 -y copr enable marcelohdez/dim
sudo dnf5 install -y dim-screen
dnf5 -y copr disable marcelohdez/dim

dnf5 -y copr enable erikreider/SwayNotificationCenter
sudo dnf5 -y install SwayNotificationCenter
dnf5 -y copr enable erikreider/SwayNotificationCenter

#### Example for enabling a System Unit File

systemctl enable rsyslog
systemctl enable podman.socket
systemctl enable libvirtd
