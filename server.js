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

/**
 * Swagger setup
 */
const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'Login Service API',
      version: '1.0.0',
      description: 'API documentation for Login and User Authentication',
    },
    servers: [
      {
        url: 'http://localhost:3005',
        description: 'Local development server'
      },
      {
        url: 'https://info.ea2sa.com',
        description: 'Production server'
      },
    ],
  },
  apis: ['./routes/*.js'],
};
const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

/**
 * Routes
 */
app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3005;
const HOST = '0.0.0.0';

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, HOST, () => {
    console.log(`Login Service running on http://${HOST}:${PORT}`);
    console.log(`Swagger docs available at http://${HOST}:${PORT}/api-docs`);
  });
}

module.exports = app;
