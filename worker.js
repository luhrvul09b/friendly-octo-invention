export default {
  async fetch(request, env, ctx) {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader.toLowerCase() !== 'websocket') {
      return new Response('🚀 SSHmax Style Private CDN Panel Active!', {
        status: 200,
        headers: { 'Content-Type': 'text/plain' }
      });
    }

    const RAILWAY_TCP_HOST = 'thomas.proxy.rlwy.net'; 
    const RAILWAY_TCP_PORT = 33663;

    try {
      const tcpSocket = connect({ hostname: RAILWAY_TCP_HOST, port: RAILWAY_TCP_PORT });
      const [client, server] = Object.values(new WebSocketPair());

      server.accept();

      server.addEventListener('message', async (event) => {
        const writer = tcpSocket.writable.getWriter();
        if (typeof event.data === 'string') {
          await writer.write(new TextEncoder().encode(event.data));
        } else {
          await writer.write(event.data);
        }
        writer.releaseLock();
      });

      (async () => {
        const reader = tcpSocket.readable.getReader();
        try {
          while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            server.send(value);
          }
        } catch (e) {
        } finally {
          reader.releaseLock();
        }
      })();

      return new Response(null, { status: 101, webSocket: client });

    } catch (err) {
      return new Response('❌ Connection Failed: ' + err.message, { status: 500 });
    }
  },
};
