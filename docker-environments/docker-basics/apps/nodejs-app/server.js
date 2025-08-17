const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.static('public'));

// Configuration PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://labuser:labpass@localhost:5432/labdb',
});

// Configuration Redis
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

// Connexion Redis
redisClient.on('error', (err) => console.log('Redis Client Error', err));
redisClient.connect();

// Routes

// Page d'accueil
app.get('/', (req, res) => {
  res.json({
    message: '🐳 Docker Node.js App',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Health check
app.get('/health', async (req, res) => {
  try {
    // Test PostgreSQL
    const pgResult = await pool.query('SELECT NOW()');
    
    // Test Redis
    await redisClient.ping();
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        redis: 'connected'
      },
      uptime: process.uptime()
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// API Users
app.get('/api/users', async (req, res) => {
  try {
    // Vérifier le cache Redis
    const cached = await redisClient.get('users');
    if (cached) {
      return res.json({
        data: JSON.parse(cached),
        source: 'cache'
      });
    }

    // Requête base de données
    const result = await pool.query('SELECT id, name, email, created_at FROM users ORDER BY created_at DESC');
    
    // Mettre en cache pour 5 minutes
    await redisClient.setEx('users', 300, JSON.stringify(result.rows));
    
    res.json({
      data: result.rows,
      source: 'database'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Créer un utilisateur
app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    
    if (!name || !email) {
      return res.status(400).json({ error: 'Name and email are required' });
    }

    const result = await pool.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    );

    // Invalider le cache
    await redisClient.del('users');

    res.status(201).json({
      message: 'User created successfully',
      user: result.rows[0]
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Compteur de visites avec Redis
app.get('/api/counter', async (req, res) => {
  try {
    const count = await redisClient.incr('visit_counter');
    res.json({
      visits: count,
      message: `Cette page a été visitée ${count} fois`
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Informations système
app.get('/api/info', (req, res) => {
  res.json({
    hostname: require('os').hostname(),
    platform: require('os').platform(),
    arch: require('os').arch(),
    nodeVersion: process.version,
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + ' MB'
    },
    uptime: Math.round(process.uptime()) + ' seconds',
    pid: process.pid
  });
});

// Endpoint pour tester les erreurs
app.get('/api/error', (req, res) => {
  throw new Error('Test error endpoint');
});

// Middleware de gestion d'erreurs
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    error: 'Internal Server Error',
    message: error.message,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

// Initialisation de la base de données
async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Insérer des données d'exemple
    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    if (parseInt(userCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO users (name, email) VALUES 
        ('Alice Dupont', 'alice@example.com'),
        ('Bob Martin', 'bob@example.com'),
        ('Charlie Durand', 'charlie@example.com')
      `);
      console.log('✅ Données d\'exemple insérées');
    }
  } catch (error) {
    console.error('❌ Erreur d\'initialisation de la base de données:', error);
  }
}

// Démarrage du serveur
app.listen(PORT, async () => {
  console.log(`🚀 Serveur Node.js démarré sur le port ${PORT}`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🐳 Container ID: ${require('os').hostname()}`);
  
  // Initialiser la base de données
  await initDatabase();
  
  console.log('✅ Application prête !');
});

// Gestion propre de l'arrêt
process.on('SIGTERM', async () => {
  console.log('🛑 Arrêt du serveur...');
  await pool.end();
  await redisClient.quit();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Arrêt du serveur...');
  await pool.end();
  await redisClient.quit();
  process.exit(0);
});