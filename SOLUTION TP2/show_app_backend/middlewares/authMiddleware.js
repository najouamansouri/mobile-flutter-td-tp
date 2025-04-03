const jwt = require('jsonwebtoken');
const SECRET_KEY = process.env.JWT_SECRET || 'secretkey';

module.exports = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(403).json({ error: 'Token manquant' });

  jwt.verify(token, SECRET_KEY, (err, decoded) => {
    if (err) return res.status(403).json({ error: 'Token invalide' });
    req.userId = decoded.userId;
    next();
  });
};