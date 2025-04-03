const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../database');
const router = express.Router();
require('dotenv').config();

const SECRET_KEY = process.env.JWT_SECRET || 'secretkey';

// Inscription
router.post('/register', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email et mot de passe requis' });

  const hashedPassword = await bcrypt.hash(password, 10);

  db.run('INSERT INTO users (email, password) VALUES (?, ?)', [email, hashedPassword], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Utilisateur créé', userId: this.lastID });
  });
});

// Connexion
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email et mot de passe requis' });

  db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!user) return res.status(401).json({ error: 'Identifiants invalides' });

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) return res.status(401).json({ error: 'Identifiants invalides' });

    const token = jwt.sign({ userId: user.id }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });
  });
});

module.exports = router;