import { getDb } from '../../lib/db.js';
import { getSession } from '../../lib/session.js';

export default async function handler(req, res) {
  const session = getSession(req);
  if (!session || session.role !== 'admin') return res.status(403).json({ error: 'Accès refusé' });

  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { chapter_id, card_id, question, options, correct_index, explanation, difficulty, source } = req.body;
  if (!chapter_id || !question || !options || correct_index === undefined || !explanation) {
    return res.status(400).json({ error: 'Champs requis manquants' });
  }

  try {
    const sql = getDb();
    const rows = await sql`
      INSERT INTO questions (chapter_id, card_id, question, options, correct_index, explanation, difficulty, source)
      VALUES (${chapter_id}, ${card_id || null}, ${question}, ${JSON.stringify(options)},
        ${correct_index}, ${explanation}, ${difficulty || 'medium'}, ${source || null})
      RETURNING *
    `;
    return res.status(201).json({ question: rows[0] });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
