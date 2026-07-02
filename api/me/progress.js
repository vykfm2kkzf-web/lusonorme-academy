import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session) return res.status(401).json({ error: 'Non authentifié' });

  try {
    const sql = getDb();
    const chapters = await sql`
      SELECT c.id, c.slug, c.title, c.icon, c.description,
        (SELECT COUNT(*) FROM cards WHERE chapter_id = c.id AND published = true) as total_cards,
        (SELECT COUNT(*) FROM user_card_progress ucp
          JOIN cards ca ON ca.id = ucp.card_id
          WHERE ca.chapter_id = c.id AND ucp.user_id = ${session.id}) as cards_read,
        (SELECT COUNT(*) FROM quiz_results WHERE chapter_id = c.id AND user_id = ${session.id}) as quiz_attempts,
        (SELECT ROUND(MAX(score::float / total * 100)) FROM quiz_results
          WHERE chapter_id = c.id AND user_id = ${session.id}) as best_score_pct
      FROM chapters c WHERE c.published = true ORDER BY c.position
    `;
    return res.status(200).json({ chapters, user: session });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
