import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session || session.role !== 'admin') return res.status(403).json({ error: 'Accès refusé' });
  const sql = getDb();

  if (req.method === 'POST') {
    const { chapter_id, title, content, source, source_url, key_figures, position } = req.body;
    if (!chapter_id || !title || !content) return res.status(400).json({ error: 'Champs requis manquants' });
    try {
      const rows = await sql`
        INSERT INTO cards (chapter_id, title, content, source, source_url, key_figures, position)
        VALUES (${chapter_id}, ${title}, ${content}, ${source}, ${source_url},
          ${JSON.stringify(key_figures || [])}, ${position || 0})
        RETURNING *
      `;
      return res.status(201).json({ card: rows[0] });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Erreur serveur' });
    }
  }
  return res.status(405).json({ error: 'Method not allowed' });
}
