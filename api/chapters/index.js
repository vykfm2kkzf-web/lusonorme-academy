import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session) return res.status(401).json({ error: 'Non authentifié' });

  try {
    const sql = getDb();
    const chapters = await sql`
      SELECT c.*,
        (SELECT COUNT(*) FROM cards WHERE chapter_id = c.id AND published = true) as card_count,
        (SELECT COUNT(*) FROM questions WHERE chapter_id = c.id AND published = true) as question_count
      FROM chapters c WHERE c.published = true ORDER BY c.position
    `;
    return res.status(200).json({ chapters });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
