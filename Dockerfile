FROM ubuntu:22.04

RUN sed -i "s/http:\/\/archive.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
    sed -i "s/http:\/\/security.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

RUN apt-get update && \ 
    apt-get -y install sudo openssh-server cron rsyslog 

RUN touch /etc/default/locale 
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
COPY ./src/rsyslog.conf /etc/rsyslog.d/console.conf

ADD ./src/crontab /etc/cron.d/hello-cron
RUN chmod 0644 /etc/cron.d/hello-cron
RUN touch /var/log/cron.log
RUN crontab /etc/cron.d/hello-cron

RUN useradd -m ctf && echo "ctf:ctf" && \
    echo "ctf:ctf" | chpasswd

RUN ssh-keygen -A && \
    /etc/init.d/ssh start && \
    chsh -s /bin/bash ctf

COPY ./src/sudoers /etc/sudoers
COPY ./service/docker-entrypoint.sh /
COPY ./src/sshd_config /etc/ssh/sshd_config
COPY ./src/crontab /etc/crontab

ENTRYPOINT ["/bin/bash","/docker-entrypoint.sh"]