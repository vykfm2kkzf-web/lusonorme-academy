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

    if (req.method === 'GET') {
      const questions = await sql`
        SELECT id, question, options, difficulty, source
        FROM questions
        WHERE chapter_id = ${chapter.id} AND published = true
        ORDER BY RANDOM() LIMIT 5
      `;
      return res.status(200).json({ chapter, questions });
    }

    if (req.method === 'POST') {
      const { answers } = req.body;
      if (!answers?.length) return res.status(400).json({ error: 'Réponses manquantes' });

      const ids = answers.map(a => a.question_id);
      const questions = await sql`SELECT id, correct_index, explanation FROM questions WHERE id = ANY(${ids})`;
      const qMap = Object.fromEntries(questions.map(q => [q.id, q]));

      let score = 0;
      const enriched = answers.map(a => {
        const q = qMap[a.question_id];
        const correct = q && a.selected_index === q.correct_index;
        if (correct) score++;
        return { ...a, correct, explanation: q?.explanation, correct_index: q?.correct_index };
      });

      await sql`
        INSERT INTO quiz_results (user_id, chapter_id, score, total, answers)
        VALUES (${session.id}, ${chapter.id}, ${score}, ${answers.length}, ${JSON.stringify(enriched)})
      `;
      return res.status(200).json({ score, total: answers.length, answers: enriched });
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
