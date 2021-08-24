const WebSocket = require('ws');
 
module.exports = (server) => {
    const wss = new WebSocket.Server({
        server
    });
 
    wss.broadcast = (ws, data) => {
        wss.clients.forEach((client) => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                console.log(`onBroadcast`)
                client.send(data);
            }
        });
    };

    wss.on('connection', (ws) => {
        console.log('On Connection');
        
        ws.on('message', (data) => {
            console.log(`onMessage: ${data}`);
            wss.broadcast(ws, data);
        });
        
        ws.on('error', (error) => {
            console.error(`onError: ${error.message}`);
        });
    });
 
    console.log(`App Web Socket Server is running!`);
    return wss;
}