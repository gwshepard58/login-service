require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const session = require('express-session');
const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(session({
  secret: 'northwind-secret',
  resave: false,
  saveUninitialized: true
}));

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3005;
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Login service running on port ${PORT}`);
  });
}

module.exports = app;
