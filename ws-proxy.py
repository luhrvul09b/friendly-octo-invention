import socket
import threading
import select

def handle_client(client_socket):
    try:
        request = client_socket.recv(4096).decode('utf-8', errors='ignore')
        if "Upgrade: websocket" in request or "HTTP/1.1" in request:
            # Sshmax jaisa direct response bina kisi 301 ke
            response = (
                "HTTP/1.1 101 Switching Protocols\r\n"
                "Upgrade: websocket\r\n"
                "Connection: Upgrade\r\n\r\n"
            )
            client_socket.sendall(response.encode())
            
            # Local SSH Port 22
            ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ssh_socket.connect(('127.0.0.1', 22))
            
            sockets = [client_socket, ssh_socket]
            while True:
                readable, _, _ = select.select(sockets, [], [], 60)
                if not readable: break
                for s in readable:
                    if s is client_socket:
                        data = client_socket.recv(8192)
                        if not data: return
                        ssh_socket.sendall(data)
                    elif s is ssh_socket:
                        data = ssh_socket.recv(8192)
                        if not data: return
                        client_socket.sendall(data)
    except:
        pass
    finally:
        client_socket.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', 8080))
    server.listen(500)
    print("Sshmax style proxy running on port 8080...")
    while True:
        try:
            client, _ = server.accept()
            threading.Thread(target=handle_client, args=(client,), daemon=True).start()
        except:
            break

if __name__ == '__main__':
    main()
