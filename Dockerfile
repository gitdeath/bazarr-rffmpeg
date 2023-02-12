FROM linuxserver/bazarr:latest

RUN apk add --no-cache openssh-client py3-click py3-yaml wget
    
RUN mkdir -p /usr/local/bin && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg && \
    chmod +x /usr/local/bin/rffmpeg && \
    rm /usr/bin/ffmpeg && \
    rm /usr/bin/ffprobe && \
    ln -s /usr/local/bin/rffmpeg /usr/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/bin/ffprobe
    
RUN mkdir -p /config/rffmpeg && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg.yml.sample -O /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#logfile: "/var/log/jellyfin/rffmpeg.log";logfile: "/config/log/rffmpeg.log";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogfiles: false;datedlogfiles: true;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogdir: "/var/log/jellyfin";datedlogdir "/config/log";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#state: "/var/lib/rffmpeg";state: "/config/rffmpeg";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#persist: "/run/shm";persist: "/sshpersist";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#owner: jellyfin;owner: abc;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#group: sudo;group: users;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#user: jellyfin;user: root;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#args:;args:;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "-i";    - "-i";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "/var/lib/jellyfin/id_rsa";    - "/config/rffmpeg/.ssh/id_rsa";' /config/rffmpeg/rffmpeg.yml 
    
RUN mkdir -p /etc/rffmpeg && \
    ln -s /config/rffmpeg/rffmpeg.yml /etc/rffmpeg/rffmpeg.yml
    
RUN /usr/local/bin/rffmpeg init -y && \
    mkdir -p /config/rffmpeg/.ssh && \
    chmod 700 /config/rffmpeg/.ssh && \
    ssh-keygen -t rsa -f /config/rffmpeg/.ssh/id_rsa -q -N ""

RUN mkdir -p /root/.ssh && \
    mkdir -p /sshpersist && \
    chgrp users /sshpersist && \
    chmod 664 /sshpersist

RUN usermod -a -G users root

RUN sed -i 's;#   IdentityFile ~/.ssh/id_rsa;   IdentityFile /config/rffmpeg/.ssh/id_rsa;' /etc/ssh/ssh_config && \
    sed -i 's;#   UserKnownHostsFile ~/.ssh/known_hosts.d/%k;   UserKnownHostsFile /config/rffmpeg/.ssh/known_hosts;' /etc/ssh/ssh_config 

    
