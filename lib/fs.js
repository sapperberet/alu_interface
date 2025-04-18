const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
  // Add CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*'); // allow all origins
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight request (OPTIONS)
  if (req.method === 'OPTIONS') {
    res.writeHead(204); // No Content
    return res.end();
  }

  const parsedUrl = url.parse(req.url, true);
  const { pathname, query } = parsedUrl;

  // change path "/log" to whatever you were working with in the app
  if (pathname === '/log' && req.method === 'GET') {
    const message = query.msg || 'No message sent';
    console.log(`📝 Message from client: ${message}`);

    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Received message: ${message}`);
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Route not found\n');
  }
});

const PORT = 3000;
server.listen(PORT, 'localhost', () => {
  console.log(`Server running on http://localhost:${PORT}`);
});