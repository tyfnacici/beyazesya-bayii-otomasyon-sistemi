require('dotenv').config();
const express = require('express');
const api = require('./routes/index.js');
const connection = require('./service/connection.js');

const app = express();

connection.getConnection((err) => {
  if (err) throw err;
  console.log('Connected!');
  app.listen(3000, () => {
    console.log('Server is running at port 3000');
  })
});

app.use('/', api)

process.on("exit",()=>{pool.end(console.log("All connections are closing!"));})
