import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  const session = getSession(req);
  if (!session) return res.status(401).json({ error: 'Non authentifié' });
  const { card_id } = req.body;

  try {
    const sql = getDb();
    await sql`
      INSERT INTO user_card_progress (user_id, card_id)
      VALUES (${session.id}, ${card_id})
      ON CONFLICT (user_id, card_id) DO NOTHING
    `;
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
