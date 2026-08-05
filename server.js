const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Allow any Host header (essential for secure proxy compatibility)
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', '*');
  next();
});

// Serve static assets from the public folder
app.use(express.static(path.join(__dirname, 'public')));

// Fallback to serving public/index.html safely for all requests
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Pause companion server listening on 0.0.0.0:${PORT}`);
});
