const express = require('express');
const path = require('path');

const app = express();

// Statische Dateien aus dem "public"-Ordner ausliefern (index.html + Katzenbilder)
app.use(express.static(path.join(__dirname, 'public')));

// Elastic Beanstalk (Node.js-Plattform) stellt den Port über process.env.PORT bereit
const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`Container of Cats läuft auf Port ${port} 🐾`);
});
