let mysql = require("mysql");
require('dotenv').config();
const express = require('express');

const connection = mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
  port: process.env.MYSQL_PORT
})

const app = express();

connection.connect((err) => {
  if (err) throw err;
  console.log('Connected!');
  app.listen(3000, () => {
    console.log('Server is running at port 3000');
  })
});


app.get('/api/', (req, res) => {
  res.send('Hello World!')
})

