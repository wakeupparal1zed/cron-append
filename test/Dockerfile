FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       openssh-server \
       ca-certificates \
       tzdata \
       nano \
       cron \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd /opt/ctf

ARG CTF_USER=ctf
ARG CTF_HOME=/home/${CTF_USER}
RUN useradd -m -d ${CTF_HOME} -s /bin/bash ${CTF_USER}

RUN sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -ri 's|^#?PrintMotd.*|PrintMotd yes|' /etc/ssh/sshd_config \
    && sed -ri 's|^#?UsePAM.*|UsePAM yes|' /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENV CTF_USER=ctf \
    CTF_PASS=ctf123 \
    FLAG=vsosh{testflag}

RUN printf "\nДобро пожаловать!\n\n" \
         > /etc/motd

CMD ["/entrypoint.sh"]
