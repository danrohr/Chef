########################################
# Make SELinux Configuration Immutable
########################################
chattr +i /etc/selinux/config


########################################
# Disable Control-Alt-Delete
########################################
ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target


########################################
# No Root Login to Console (use admin user)
########################################
#cat /dev/null > /etc/securetty

########################################
# Disable Interactive Shell (Timeout)
########################################
cat <<EOF > /etc/profile.d/autologout.sh
#!/bin/sh
TMOUT=900
readonly TMOUT
export TMOUT
EOF
cat <<EOF > /etc/profile.d/autologout.csh
#!/bin/csh
set autologout=15
set -r autologout
EOF
chown root:root /etc/profile.d/autologout.sh
chown root:root /etc/profile.d/autologout.csh
chmod 755 /etc/profile.d/autologout.sh
chmod 755 /etc/profile.d/autologout.csh


########################################
# Vlock Alias (Cosole Screen Lock)
########################################
cat <<EOF > /etc/profile.d/vlock-alias.sh
#!/bin/sh
alias vlock='clear;vlock -a'
EOF
cat <<EOF > /etc/profile.d/vlock-alias.csh
#!/bin/csh
alias vlock 'clear;vlock -a'
EOF
chown root:root /etc/profile.d/vlock-alias.sh
chown root:root /etc/profile.d/vlock-alias.csh
chmod 755 /etc/profile.d/vlock-alias.sh
chmod 755 /etc/profile.d/vlock-alias.csh


########################################
# Wheel Group Require (sudo)
########################################
sed -i -re '/pam_wheel.so use_uid/s/^#//' /etc/pam.d/su
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/' /etc/sudoers
echo -e "\n## Set timeout for authentiation (5 Minutes)\nDefaults:ALL timestamp_timeout=5\n" >> /etc/sudoers


########################################
# Set Removeable Media to noexec
#   CCE-27196-5
########################################
for DEVICE in $(/bin/lsblk | grep sr | awk '{ print $1 }'); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,noauto\t0 0" >> /etc/fstab
done
for DEVICE in $(cd /dev;ls *cd* *dvd*); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,noauto\t0 0" >> /etc/fstab
done

########################################
# SSHD Hardening
########################################
sed -i '/Ciphers aes/d' /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1" >> /etc/ssh/sshd_config
echo "#AllowGroups sshusers" >> /etc/ssh/sshd_config
echo "#MaxAuthTries 3" >> /etc/ssh/sshd_config
echo "Banner /etc/issue" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
echo "KerberosAuthentication no" >> /etc/ssh/sshd_config
echo "#StrictModes yes" >> /etc/ssh/sshd_config
echo "#UsePrivilegeSeparation yes" >> /etc/ssh/sshd_config
echo "Compression delayed" >> /etc/ssh/sshd_config
#if [ $(grep -c sshusers /etc/group) -eq 0 ]; then
#	/usr/sbin/groupadd sshusers &> /dev/null
#fi

########################################
# TCP_WRAPPERS
########################################
cat <<EOF >> /etc/hosts.allow
# LOCALHOST (ALL TRAFFIC ALLOWED) DO NOT REMOVE FOLLOWING LINE
ALL: 127.0.0.1 [::1]
# Allow SSH (you can limit this further using IP addresses - e.g. 192.168.0.*)
sshd: ALL
EOF
cat <<EOF >> /etc/hosts.deny
# Deny All by Default
#ALL: ALL
EOF


########################################
# Filesystem Attributes
#  CCE-26499-4,CCE-26720-3,CCE-26762-5,
#  CCE-26778-1,CCE-26622-1,CCE-26486-1.
#  CCE-27196-5
########################################
FSTAB=/etc/fstab
SED=`which sed`

if [ $(grep " \/sys " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/sys " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/sys.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/boot " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/boot " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/boot.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/export\/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/export\/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/export\/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr\/local " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr\/local " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr\/local.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/dev\/shm " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/dev\/shm " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/dev\/shm.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log\/audit " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/log\/audit " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/log\/audit.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/www " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/wwww " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/www.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/opt " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/opt " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/opt.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
echo -e "tmpfs\t\t\t/dev/shm\t\ttmpfs\tnoexec,nosuid,nodev\t\t0 0" >> /etc/fstab

########################################
# File Ownership 
########################################
find / -nouser -print | xargs chown root
find / -nogroup -print | xargs chown :root
cat <<EOF > /etc/cron.daily/unowned_files
#!/bin/sh
# Fix user and group ownership of files without user
find / -nouser -print | xargs chown root
find / -nogroup -print | xargs chown :root
EOF
chown root:root /etc/cron.daily/unowned_files
chmod 0700 /etc/cron.daily/unowned_files


########################################
# AIDE Initialization
########################################
if [ ! -e /var/lib/aide/aide.db.gz ]; then
	echo "Initializing AIDE database, this step may take quite a while!"
	/usr/sbin/aide --init &> /dev/null
	echo "AIDE database initialization complete."
	cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi
cat <<EOF > /etc/cron.weekly/aide-report
#!/bin/sh
# Generate Weekly AIDE Report
\`/usr/sbin/aide --check > /var/log/aide/reports/\$(hostname)-aide-report-\$(date +%Y%m%d).txt\`
EOF
chown root:root /etc/cron.weekly/aide-report
chmod 555 /etc/cron.weekly/aide-report
mkdir -p /var/log/aide/reports
chmod 700 /var/log/aide/reports


########################################
# USGCB Blacklist
########################################
if [ -e /etc/modprobe.d/usgcb-blacklist.conf ]; then
	rm -f /etc/modprobe.d/usgcb-blacklist.conf
fi
touch /etc/modprobe.d/usgcb-blacklist.conf
chmod 0644 /etc/modprobe.d/usgcb-blacklist.conf
chcon 'system_u:object_r:modules_conf_t:s0' /etc/modprobe.d/usgcb-blacklist.conf

cat <<EOF > /etc/modprobe.d/usgcb-blacklist.conf
# Disable Bluetooth
install bluetooth /bin/true
# Disable AppleTalk
install appletalk /bin/true
# NSA Recommendation: Disable mounting USB Mass Storage
#install usb-storage /bin/true
# Disable mounting of cramfs CCE-14089-7
install cramfs /bin/true
# Disable mounting of freevxfs CCE-14457-6
install freevxfs /bin/true
# Disable mounting of hfs CCE-15087-0
install hfs /bin/true
# Disable mounting of hfsplus CCE-14093-9
install hfsplus /bin/true
# Disable mounting of jffs2 CCE-14853-6
install jffs2 /bin/true
# Disable mounting of squashfs CCE-14118-4
install squashfs /bin/true
# Disable mounting of udf CCE-14871-8
install udf /bin/true
# CCE-14268-7
install dccp /bin/true
# CCE-14235-5
install sctp /bin/true
#i CCE-14027-7
install rds /bin/true
# CCE-14911-2
install tipc /bin/true
# CCE-14948-4 (row 176)
install net-pf-31 /bin/true
EOF


########################################
# GNOME 3 Lockdowns
########################################
#if [ -x /bin/gsettings ]; then
#	cat << EOF > /etc/dconf/db/gdm.d/99-gnome-hardening
#[org/gnome/login-screen]
#banner-message-enable=true
#banner-message-text="${BANNER_MESSAGE_TEXT}"
#disable-user-list=true
#disable-restart-buttons=true

#[org/gnome/desktop/lockdown]
#user-administration-disabled=true
#disable-user-switching=true

#[org/gnome/desktop/media-handling]
#automount=false
#automount-open=false
#autorun-never=true

#[org/gnome/desktop/notifications] 
#show-in-lock-screen=false

#[org/gnome/desktop/privacy]
#remove-old-temp-files=true
#remove-old-trash-files=true
#old-files-age=7

#[org/gnome/desktop/interface]
#clock-format="12h"

#[org/gnome/desktop/screensaver]
#user-switch-enabled=false

#[org/gnome/desktop/session]
#idle-delay=900

#[org/gnome/desktop/thumbnailers]
#disable-all=true

#[org/gnome/nm-applet]
#disable-wifi-create=true
#EOF
#	cat << EOF > /etc/dconf/db/gdm.d/locks/99-gnome-hardening
#/org/gnome/login-screen/banner-message-enable
#/org/gnome/login-screen/banner-message-text
#/org/gnome/login-screen/disable-user-list
#/org/gnome/login-screen/disable-restart-buttons
#/org/gnome/desktop/lockdown/user-administration-disabled
#/org/gnome/desktop/lockdown/disable-user-switching
#/org/gnome/desktop/media-handling/automount
#/org/gnome/desktop/media-handling/automount-open
#/org/gnome/desktop/media-handling/autorun-never
#/org/gnome/desktop/notifications/show-in-lock-screen
#/org/gnome/desktop/privacy/remove-old-temp-files
#/org/gnome/desktop/privacy/remove-old-trash-files
#/org/gnome/desktop/privacy/old-files-age
#/org/gnome/desktop/screensaver/user-switch-enabled
#/org/gnome/desktop/session/idle-delay
#/org/gnome/desktop/thumbnailers/disable-all
#/org/gnome/nm-applet/disable-wifi-create
#EOF
#	cat << EOF > /usr/share/glib-2.0/schemas/99-custom-settings.gschema.override
#[org.gnome.login-screen]
#banner-message-enable=true
#banner-message-text="${BANNER_MESSAGE_TEXT}"
#disable-user-list=true
#disable-restart-buttons=true

#[org.gnome.desktop.lockdown]
#user-administration-disabled=true
#disable-user-switching=true

#[org.gnome.desktop.media-handling]
#automount=false
#automount-open=false
#autorun-never=true

#[org.gnome.desktop.notifications] 
#show-in-lock-screen=false

#[org.gnome.desktop.privacy]
#remove-old-temp-files=true
#remove-old-trash-files=true
#old-files-age=7

#[org.gnome.desktop.interface]
#clock-format="12h"

#[org.gnome.desktop.screensaver]
#user-switch-enabled=false

#[org.gnome.desktop.session]
#idle-delay=900

#[org.gnome.desktop.thumbnailers]
#disable-all=true

#[org.gnome.nm-applet]
#disable-wifi-create=true
#EOF
#	cp /etc/dconf/db/gdm.d/locks/99-gnome-hardening /etc/dconf/db/local.d/locks/99-gnome-hardening
# 	/bin/glib-compile-schemas /usr/share/glib-2.0/schemas/
#	/bin/dconf update
#fi

########################################
# Disable Pre-Linking
# CCE-27078-5
########################################
if grep -q ^PRELINKING /etc/sysconfig/prelink; then
  sed -i 's/PRELINKING.*/PRELINKING=no/g' /etc/sysconfig/prelink
else
  echo -e "\n# Disable Pre-Linking (CCE-27078-5, CM-6(d), CM-6(3), SC-28, SI-7, Req-11.5)" >> /etc/sysconfig/prelink
  echo "PRELINKING=no" >> /etc/sysconfig/prelink
fi
/usr/sbin/prelink -ua

########################################
# Kernel - Randomize Memory Space
# CCE-27127-0, SC-30(2), 1.6.1
########################################
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf

########################################
# Kernel - Accept Source Routed Packets
# AC-4, 366, SRG-OS-000480-GPOS-00227
########################################
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf

########################################
# Disable SystemD Date Service 
# Use (chrony or ntpd)
########################################
timedatectl set-ntp false

######################################## 
# Disable Kernel Dump Service 
######################################## 
systemctl disable kdump.service 
systemctl mask kdump.service
