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
RUN useradd -m -s /bin/bash yomi && echo "yomi:password123" | chpasswd

# Ngrok Install karein
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.p9/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list \
    && apt-get update && apt-get install ngrok -y

WORKDIR /app
COPY ws-proxy.py /app/ws-proxy.py

EXPOSE 8080

# NGROK_TOKEN ko hum Railway variables se uthaein ge
CMD service ssh start && python3 /app/ws-proxy.py & ngrok tcp 8080 --authtoken $NGROK_TOKEN
