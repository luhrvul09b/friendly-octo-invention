FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# SSH Directory aur basic setup
RUN mkdir /var/run/sshd
RUN echo 'root:password123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH User jo aap app mein use karenge
RUN useradd -m -s /bin/bash yomi && echo "yomi:password123" | chpasswd

WORKDIR /app
COPY ws-proxy.py /app/ws-proxy.py

# Railway default par PORT environment variable deta hai, hum port 8080 expose kar rahe hain
EXPOSE 8080

CMD service ssh start && python3 /app/ws-proxy.py
