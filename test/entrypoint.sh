#!/bin/bash
set -euo pipefail

CTF_USER=${CTF_USER:-ctf}
CTF_PASS=${CTF_PASS:-ctf123}
FLAG=${FLAG}
CTF_HOME=/home/${CTF_USER}
SSH_PORT=${SSH_PORT:-22}

if ! id -u "$CTF_USER" >/dev/null 2>&1; then
  useradd -m -d "$CTF_HOME" -s /bin/bash "$CTF_USER"
fi

echo "${CTF_USER}:${CTF_PASS}" | chpasswd

if grep -qE '^#?Port ' /etc/ssh/sshd_config; then
  sed -ri "s/^#?Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
else
  echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config
fi

# Lock down common escalation paths; leave only intended cron path
if [ -f /bin/su ]; then chmod 700 /bin/su; fi
if [ -f /usr/bin/su ]; then chmod 700 /usr/bin/su; fi
find / -xdev -type f -perm -4000 2>/dev/null | while read -r f; do
  chmod u-s "$f" 2>/dev/null || true
done

mkdir -p /opt/ctf/cron

FLAG_PATH=/root/flag.txt
printf "%s\n" "$FLAG" > "$FLAG_PATH"
chown root:root "$FLAG_PATH"
chmod 600 "$FLAG_PATH"

cat > /opt/ctf/cron/backup.sh <<'SCRIPT'
#!/bin/bash
# Harmless placeholder job
/bin/date >> /var/log/backup.log
SCRIPT

chown root:ctf /opt/ctf/cron/backup.sh
chmod 770 /opt/ctf/cron/backup.sh

# Root cron job executes the script every minute
if ! grep -q "/opt/ctf/cron/backup.sh" /etc/crontab; then
  echo "* * * * * root /opt/ctf/cron/backup.sh >/dev/null 2>&1" >> /etc/crontab
fi

cat >/etc/motd <<'MOTD'
Добро пожаловать!

Цель: получить флаг, используя cron job.
Ищите скрипт, который выполняется от root и который можно изменить.
MOTD

cat >"$CTF_HOME"/WELCOME.txt <<'EOF2'
Добро пожаловать!
Подсказка: проверьте /etc/crontab и /opt/ctf/cron/.
EOF2
chown ${CTF_USER}:${CTF_USER} "$CTF_HOME"/WELCOME.txt

unset FLAG

cron
exec /usr/sbin/sshd -D -e
