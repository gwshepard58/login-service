const pool = require('../config/db');
const bcrypt = require('bcrypt');

// Register new user
exports.register = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const query = `
      INSERT INTO users (username, email, password_hash, created_at, updated_at)
      VALUES ($1, $2, $3, NOW(), NOW())
      RETURNING user_id, username, email
    `;

    const values = [username, email, hashedPassword];
    const result = await pool.query(query, values);

    res.status(201).json({
      message: 'User registered',
      user: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Login user
exports.login = async (req, res) => {
  const { username, password } = req.body;

  try {
    const query = `SELECT * FROM users WHERE username = $1`;
    const result = await pool.query(query, [username]);

    const user = result.rows[0];
    if (!user) return res.status(401).json({ error: 'Invalid username or password' });

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Invalid username or password' });

    req.session.user = {
      id: user.user_id,
      username: user.username,
      email: user.email
    };

    res.json({ message: 'Login successful', user: req.session.user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get user profile
exports.profile = (req, res) => {
  if (!req.session.user) return res.status(401).json({ error: 'Unauthorized' });

  res.json({ user: req.session.user });
};
