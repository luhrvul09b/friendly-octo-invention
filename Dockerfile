FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server && rm -rf /var/lib/apt/lists/*

# SSH Configuration
RUN mkdir /var/run/sshd
RUN echo 'root:password123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Web user generate karein
RUN useradd -m -s /bin/bash yomi && echo "yomi:password123" | chpasswd

# Railway par standard port expose karein
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
