require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const api = require('./routes/index.js');
const connection = require('./service/connection.js');

const app = express();
app.use(bodyParser.json());
connection.getConnection((err) => {
  if (err) throw err;
  console.log('Connected!');
  const server = app.listen(3000, () => {
    console.log('Server is running at port 3000');
  })
});

app.use('/', api)


//Uygulama kapatıldığında tüm bağlantıları kapatır
process.on('SIGINT', function() {
  connection.end((err) => {
    console.log(err);
    process.exit(1);
  });
  console.log("\nBağlantılar sonlandırılıyor...")
  process.exit(0);
});