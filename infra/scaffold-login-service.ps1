param (
    [string]$ServiceName = "login-service",
    [int]$Port = 3005
)

# Create project directory
New-Item -ItemType Directory -Force -Path $ServiceName | Out-Null
Set-Location $ServiceName

# Create folders
New-Item -ItemType Directory -Force -Path routes,controllers,config,tests | Out-Null

# Create package.json
@"
{
  "name": "$ServiceName",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "jest"
  },
  "dependencies": {
    "bcrypt": "^5.1.1",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.18.2",
    "express-session": "^1.18.2",
    "pg": "^8.16.3",
    "swagger-jsdoc": "^6.2.8",
    "swagger-ui-express": "^4.6.3"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^7.1.4"
  }
}
"@ | Out-File package.json -Encoding UTF8

# Create .env
@"
PORT=$Port
DB_HOST=db
DB_PORT=5432
DB_USER=gary
DB_PASS=Spen1cer
DB_NAME=users
SESSION_SECRET=northwind-secret
"@ | Out-File .env -Encoding UTF8

# Create server.js
@"
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Swagger setup
const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'Login Service API',
      version: '1.0.0',
      description: 'API documentation for Login Service',
    },
    servers: [{ url: 'http://localhost:$Port' }]
  },
  apis: ['./routes/*.js'],
};
const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Routes
app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || $Port;
const HOST = '0.0.0.0';
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, HOST, () => {
    console.log(`Login Service running on http://${HOST}:${PORT}`);
    console.log(`Swagger docs available at http://${HOST}:${PORT}/api-docs`);
  });
}

module.exports = app;
"@ | Out-File server.js -Encoding UTF8

# Create authRoutes.js
@"
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: User authentication
 */
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/profile', authController.profile);

module.exports = router;
"@ | Out-File routes/authRoutes.js -Encoding UTF8

# Create authController.js
@"
const bcrypt = require('bcrypt');
const pool = require('../config/db');

exports.register = async (req, res) => {
  const { username, email, password } = req.body;
  try {
    const hashed = await bcrypt.hash(password, 12);
    await pool.query('INSERT INTO users (username, email, password) VALUES ($1, $2, $3)', [username, email, hashed]);
    res.status(201).json({ message: 'User registered successfully!' });
  } catch (err) {
    res.status(500).json({ error: 'Registration failed', details: err.message });
  }
};

exports.login = async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (result.rows.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

    const user = result.rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });

    req.session = { user: { id: user.id, username: user.username, email: user.email } };
    res.json({ message: 'Login successful', user: req.session.user });
  } catch (err) {
    res.status(500).json({ error: 'Login failed', details: err.message });
  }
};

exports.profile = (req, res) => {
  if (!req.session || !req.session.user) return res.status(401).json({ error: 'Unauthorized' });
  res.json({ profile: req.session.user });
};
"@ | Out-File controllers/authController.js -Encoding UTF8

# Create db.js
@"
const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME
});
module.exports = pool;
"@ | Out-File config/db.js -Encoding UTF8

# Create Dockerfile
@"
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE $Port
CMD ["node", "server.js"]
"@ | Out-File Dockerfile -Encoding UTF8

# Create docker-compose.yml
@"
version: "3.9"
services:
  login-service:
    build: .
    ports:
      - "$Port:$Port"
    env_file: .env
    depends_on:
      - db
  db:
    image: postgres:14
    environment:
      POSTGRES_USER: gary
      POSTGRES_PASSWORD: Spen1cer
      POSTGRES_DB: users
    ports:
      - "5433:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
"@ | Out-File docker-compose.yml -Encoding UTF8

Write-Host "Scaffold for $ServiceName created successfully!"
