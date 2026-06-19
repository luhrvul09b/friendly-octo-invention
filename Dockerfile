FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# SSH Config
RUN mkdir /var/run/sshd
RUN echo 'root:password123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH User Create Karein
RUN useradd -m -s /bin/bash yomi && echo "yomi:password123" | chpasswd

# Cloudflared (Cloudflare Tunnel) Install karein
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

WORKDIR /app
COPY ws-proxy.py /app/ws-proxy.py

EXPOSE 8080

# Script aur Cloudflare Quick Tunnel ek sath start karne ke liye
CMD service ssh start && python3 /app/ws-proxy.py & cloudflared tunnel --url http://localhost:8080
