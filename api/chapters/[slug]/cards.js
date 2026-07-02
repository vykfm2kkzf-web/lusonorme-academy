import { getDb } from '../../../lib/db.js';
import { getSession } from '../../../lib/session.js';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session) return res.status(401).json({ error: 'Non authentifié' });
  const { slug } = req.query;

  try {
    const sql = getDb();
    const chapters = await sql`SELECT * FROM chapters WHERE slug = ${slug} AND published = true`;
    if (!chapters.length) return res.status(404).json({ error: 'Chapitre introuvable' });
    const chapter = chapters[0];

    const cards = await sql`
      SELECT ca.*,
        (SELECT read_at FROM user_card_progress WHERE user_id = ${session.id} AND card_id = ca.id) as read_at
      FROM cards ca
      WHERE ca.chapter_id = ${chapter.id} AND ca.published = true
      ORDER BY ca.position
    `;
    return res.status(200).json({ chapter, cards });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
