import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';
import bcrypt from 'bcryptjs';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session || session.role !== 'admin') return res.status(403).json({ error: 'Accès refusé' });

  const sql = getDb();

  if (req.method === 'GET') {
    try {
      const users = await sql`
        SELECT u.id, u.name, u.email, u.role, u.created_at, u.last_login,
          (SELECT COUNT(*) FROM user_card_progress WHERE user_id = u.id) as cards_read,
          (SELECT COUNT(*) FROM quiz_results WHERE user_id = u.id) as quizzes_done,
          (SELECT ROUND(AVG(score::float / total * 100)) FROM quiz_results WHERE user_id = u.id) as avg_score
        FROM users u ORDER BY u.name
      `;
      return res.status(200).json({ users });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  if (req.method === 'POST') {
    const { name, email, password, role } = req.body;
    if (!name || !email || !password) return res.status(400).json({ error: 'Champs requis manquants' });
    try {
      const hash = await bcrypt.hash(password, 10);
      const rows = await sql`
        INSERT INTO users (name, email, password_hash, role)
        VALUES (${name}, ${email.toLowerCase()}, ${hash}, ${role || 'user'})
        RETURNING id, name, email, role, created_at
      `;
      return res.status(201).json({ user: rows[0] });
    } catch (err) {
      if (err.message?.includes('unique')) return res.status(409).json({ error: 'Email déjà utilisé' });
      console.error(err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
