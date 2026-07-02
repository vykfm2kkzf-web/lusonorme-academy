# Lusonorme Academy

Formation interne — Marché immobilier portugais  
Stack : HTML/JS + Vercel Functions + Vercel Postgres

---

## DÉPLOIEMENT EN 5 ÉTAPES

### 1. Pousser sur GitHub

```bash
git init
git add .
git commit -m "init lusonorme-academy"
git remote add origin https://github.com/VOTRE_COMPTE/lusonorme-academy.git
git push -u origin main
```

### 2. Créer le projet sur Vercel

- Aller sur vercel.com → New Project
- Importer le repo GitHub `lusonorme-academy`
- Laisser les paramètres par défaut
- Cliquer Deploy

### 3. Créer la base de données Postgres

- Dans votre projet Vercel → onglet Storage
- Create Database → Postgres
- Nommer la base `lusonorme-academy-db`
- Cliquer Connect → les variables d'environnement sont auto-injectées

### 4. Initialiser le schéma

- Dans Storage → onglet Query
- Copier-coller le contenu de `schema.sql`
- Exécuter

### 5. Créer les vrais mots de passe utilisateurs

Dans le terminal ou un script Node :

```javascript
const bcrypt = require('bcryptjs');
console.log(await bcrypt.hash('MotDePasseJBC!', 10));   // → hash à mettre dans la BDD
console.log(await bcrypt.hash('MotDePassePAM!', 10));   // → hash Pamella
```

Puis dans Vercel Storage → Query :
```sql
UPDATE users SET password_hash = 'HASH_ICI' WHERE email = 'jbc@lusonorme.com';
UPDATE users SET password_hash = 'HASH_ICI' WHERE email = 'pamella@lusonorme.com';
```

---

## STRUCTURE DU PROJET

```
lusonorme-academy/
├── public/
│   └── index.html          ← Application complète (SPA)
├── api/
│   ├── auth/
│   │   ├── login.js        ← POST /api/auth/login
│   │   └── logout.js       ← POST /api/auth/logout
│   ├── chapters/
│   │   ├── index.js        ← GET /api/chapters
│   │   └── [slug]/
│   │       ├── cards.js    ← GET/POST /api/chapters/:slug/cards
│   │       └── quiz.js     ← GET/POST /api/chapters/:slug/quiz
│   ├── cards/
│   │   └── read.js         ← POST /api/cards/read
│   ├── admin/
│   │   ├── users.js        ← GET/POST /api/admin/users
│   │   ├── cards.js        ← POST/PUT /api/admin/cards
│   │   └── questions.js    ← POST /api/admin/questions
│   └── me/
│       └── progress.js     ← GET /api/me/progress
├── lib/
│   └── session.js          ← Utilitaire de session
├── schema.sql              ← Schéma BDD + données initiales
├── package.json
├── vercel.json
└── README.md
```

---

## AJOUTER DU CONTENU (sans toucher au code)

### Via l'interface admin (JBC uniquement)

1. Se connecter avec le compte admin
2. Cliquer sur "Admin" dans le header
3. Onglet "Ajouter une fiche" ou "Ajouter une question"
4. Remplir le formulaire → Publier

### Chapitres disponibles

| Slug | Titre |
|------|-------|
| `offre` | L'Offre |
| `demande` | La Demande |
| `financement` | Le Financement |
| `fiscalite` | La Fiscalité |
| `acteurs` | Les Acteurs |

### Format du contenu des fiches (HTML)

```html
<p>Paragraphe d'introduction...</p>
<h3>Titre de section</h3>
<p>Texte...</p>
<ul>
  <li><strong>Point clé :</strong> explication</li>
</ul>
```

### Format des chiffres clés (JSON)

```json
[
  {"label": "Prix moyen T1 2026", "value": "262 939 €"},
  {"label": "Déficit cumulé", "value": "~300 000 logements"}
]
```

---

## ÉVOLUTION PRÉVUE

- [ ] Ajouter nouveaux épisodes Chave na Mão → nouvelles fiches + questions
- [ ] Ajouter éditions Confidencial Imobiliário → chapitre "Données de marché"
- [ ] Ajouter FAQ Unyk Place → chapitre "Le rôle du médiateur"
- [ ] Notifications par email (nouveau contenu disponible)
- [ ] Export PDF des fiches (impression)
- [ ] Tableau de bord admin agrégé (progression de toute l'équipe)

---

## CONTACTS

Administrateur : jbc@lusonorme.com  
Hébergement : Vercel (lusonorme.com ou sous-domaine academy.lusonorme.com)
