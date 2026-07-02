-- ─────────────────────────────────────────────────────────────────────────────
-- LUSONORME ACADEMY — SCHÉMA BASE DE DONNÉES
-- À exécuter dans Vercel Postgres (Storage > Query)
-- ─────────────────────────────────────────────────────────────────────────────

-- UTILISATEURS
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'user', -- 'user' | 'admin'
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP
);

-- CHAPITRES THÉMATIQUES
CREATE TABLE IF NOT EXISTS chapters (
  id SERIAL PRIMARY KEY,
  slug VARCHAR(100) UNIQUE NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  icon VARCHAR(10),
  position INTEGER DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- FICHES PÉDAGOGIQUES
CREATE TABLE IF NOT EXISTS cards (
  id SERIAL PRIMARY KEY,
  chapter_id INTEGER REFERENCES chapters(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,         -- HTML ou Markdown
  source VARCHAR(200),           -- ex: "Chave na Mão · 26 juin 2026 · Juliana Simões"
  source_url TEXT,
  key_figures JSONB,             -- [{"label": "Prix moyen T1 2026", "value": "262 939 €"}]
  position INTEGER DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- QUESTIONS DE QUIZ
CREATE TABLE IF NOT EXISTS questions (
  id SERIAL PRIMARY KEY,
  chapter_id INTEGER REFERENCES chapters(id) ON DELETE CASCADE,
  card_id INTEGER REFERENCES cards(id) ON DELETE SET NULL, -- question liée à une fiche (optionnel)
  question TEXT NOT NULL,
  options JSONB NOT NULL,        -- ["Option A", "Option B", "Option C", "Option D"]
  correct_index INTEGER NOT NULL, -- 0-3
  explanation TEXT NOT NULL,
  difficulty VARCHAR(20) DEFAULT 'medium', -- 'easy' | 'medium' | 'hard'
  source VARCHAR(200),
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- PROGRESSION UTILISATEUR (fiches lues)
CREATE TABLE IF NOT EXISTS user_card_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  card_id INTEGER REFERENCES cards(id) ON DELETE CASCADE,
  read_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, card_id)
);

-- RÉSULTATS DE QUIZ
CREATE TABLE IF NOT EXISTS quiz_results (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  chapter_id INTEGER REFERENCES chapters(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total INTEGER NOT NULL,
  answers JSONB,                 -- [{question_id, selected, correct}]
  completed_at TIMESTAMP DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- DONNÉES INITIALES — CHAPITRES
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO chapters (slug, title, description, icon, position) VALUES
('offre',       'L''Offre',        'Déficit structurel, construction, foncier, permis et délais', '🏗️', 1),
('demande',     'La Demande',      'Prix, crédit immobilier, garantie jeunes, profils acheteurs', '📈', 2),
('financement', 'Le Financement',  'Banco de Portugal, TVA, mesures prudentielles, taux d''intérêt', '🏦', 3),
('fiscalite',   'La Fiscalité',    'IRS, AIMI, IMT, plus-values, régimes bailleurs', '📋', 4),
('acteurs',     'Les Acteurs',     'Promoteurs, IHRU, APPII, banques, propriétaires, régulateur', '👥', 5)
ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- DONNÉES INITIALES — FICHES (chapitre OFFRE)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO cards (chapter_id, title, content, source, key_figures, position) VALUES

-- OFFRE / Fiche 1
(1, 'Le déficit structurel de logements au Portugal',
'<p>Le Portugal accumule un déficit de logements depuis plus d''une décennie. Ce déficit n''est pas conjoncturel : il résulte d''une production de logements structurellement inférieure à la formation de nouveaux ménages.</p>
<h3>Le chiffre clé</h3>
<p>Le Banco de Portugal estime le déficit cumulé à <strong>environ 300 000 logements</strong> sur la dernière décennie. Pour la première fois en 11 ans, 2025 a enregistré un solde positif (plus de logements produits que de ménages formés) — mais ce retournement reste fragile et partiellement dû à un ralentissement de l''immigration.</p>
<h3>Pourquoi ce déficit est structurel</h3>
<ul>
<li>La construction a été quasi à l''arrêt entre 2012 et 2020 suite à la crise financière</li>
<li>La croissance démographique (immigration) a repris bien avant la construction</li>
<li>Les délais de permis et la complexité administrative ont freiné les promoteurs</li>
<li>Le coût du foncier et de la construction a rendu de nombreux projets non viables</li>
</ul>
<h3>Ce que dit Manuel Maria Gonçalves (APPII)</h3>
<p>Le CEO de l''Association Portugaise des Promoteurs Immobiliers est explicite : <em>il n''est pas possible de résoudre en 2 ou 3 ans un déficit de logements aussi structurel.</em> Pour combler le déficit en une décennie, il faudrait <strong>tripler la production annuelle</strong> de logements.</p>',
'Chave na Mão · Expresso · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)',
'[{"label": "Déficit cumulé (Banco de Portugal)", "value": "~300 000 logements"}, {"label": "Logements licenciés en 2025", "value": "42 000"}, {"label": "Record depuis", "value": "2008"}]',
1),

-- OFFRE / Fiche 2
(1, 'La viabilité économique des projets : le vrai goulot d''étranglement',
'<p>La question centrale de la production de logements au Portugal n''est pas le manque d''appétit des promoteurs — c''est l''impossibilité de boucler économiquement de nombreux projets.</p>
<h3>Les 59 000 logements bloqués</h3>
<p>L''APPII a identifié un stock de <strong>59 000 logements</strong> dont la viabilité économique est insuffisante pour que la construction puisse avancer. Ce chiffre est reconnu par le gouvernement lui-même. Ces projets existent sur le papier, les terrains sont disponibles, les promoteurs sont prêts — mais les chiffres ne bouclent pas.</p>
<h3>La structure des coûts</h3>
<ul>
<li><strong>Foncier :</strong> 20 à 35 % du coût total d''un logement neuf. Non compressible sans intervention publique.</li>
<li><strong>Construction :</strong> coûts élevés (inflation géopolitique des matériaux, exigences techniques réglementaires).</li>
<li><strong>Taxes :</strong> la TVA à 23 % sur la construction a longtemps rendu les projets accessibles non viables.</li>
</ul>
<h3>L''exemple du T9000</h3>
<p>Manuel Maria Gonçalves illustre avec un cas concret : un programme de logements neufs à <strong>300 000–350 000 € en centre de Lisbonne</strong>. Sans réduction de TVA, le modèle n''est pas viable. Avec 75–80 % de la réduction appliquée, le seuil de viabilité est franchi. Ce n''est pas un calcul de marge — c''est un calcul binaire : <strong>construire ou ne pas construire</strong>.</p>',
'Chave na Mão · Expresso · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)',
'[{"label": "Logements bloqués (viabilité insuffisante)", "value": "59 000"}, {"label": "Part du foncier dans le coût total", "value": "20–35 %"}, {"label": "TVA construction (avant réforme)", "value": "23 %"}, {"label": "TVA construction (après réforme, juillet 2026)", "value": "6 %"}]',
2),

-- OFFRE / Fiche 3
(1, 'Le foncier et les partenariats public-privé',
'<p>Le coût du terrain est le premier facteur de blocage de la production de logements abordables au Portugal. Il représente 20 à 35 % du coût total d''un logement neuf — une part non compressible par les promoteurs seuls.</p>
<h3>Pourquoi le foncier est si cher</h3>
<ul>
<li>Disponibilité limitée dans les zones tendues (Lisbonne, Porto, Algarve)</li>
<li>Sols contaminés : coûts de dépollution non reconnus dans le prix du foncier standard</li>
<li>Morcellement de la propriété foncière, héritage de structures familiales complexes</li>
</ul>
<h3>Le levier des partenariats public-privé (PPP)</h3>
<p>La mobilisation de sols publics par les municipalités et l''État (via le droit de superficie) permet de réduire contractuellement le coût du foncier — et donc le prix de vente ou de location final. C''est le principal mécanisme pour produire du logement accessible sans subvention directe.</p>
<h3>Limite du droit de superficie</h3>
<p>Le droit de superficie (l''État reste propriétaire du sol, le promoteur construit et vend/loue le bâti) présente des contraintes de financement bancaire. Les banques sont moins à l''aise avec ce type de montage, ce qui complique le bouclage financier des projets.</p>
<h3>La simplification des permis</h3>
<p>Le nouveau dispositif législatif interdit aux municipalités d''ajouter des phases ou procédures supplémentaires au processus d''urbanisme. Effet attendu : à long terme uniquement. Le simplex urbanistique précédent ne donne ses effets que deux ans après son adoption.</p>',
'Chave na Mão · Expresso · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)',
'[{"label": "Part du foncier dans le coût d''un logement neuf", "value": "20–35 %"}, {"label": "Délai d''effet d''une réforme des permis", "value": "2 ans minimum"}]',
3);

-- ─────────────────────────────────────────────────────────────────────────────
-- DONNÉES INITIALES — FICHES (chapitre DEMANDE)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO cards (chapter_id, title, content, source, key_figures, position) VALUES

(2, 'Les prix de l''immobilier au Portugal : record historique T1 2026',
'<p>Le marché résidentiel portugais a atteint un nouveau sommet au premier trimestre 2026, avec un prix moyen de transaction de <strong>262 939 €</strong>. Ce record s''inscrit dans une tendance haussière continue depuis 2013, avec une seule inflexion notable : pour la première fois en deux ans, le <strong>rythme de croissance décélère</strong>.</p>
<h3>Ce que cette décélération signifie</h3>
<p>Il ne s''agit pas d''une baisse des prix — les prix continuent de progresser. La décélération indique que la vitesse d''augmentation ralentit. Deux interprétations possibles :</p>
<ul>
<li>Signal précoce d''un rééquilibrage (offre qui progresse, demande qui se stabilise)</li>
<li>Effet des mesures prudentielles du Banco de Portugal (resserrement du crédit)</li>
</ul>
<h3>Le contexte démographique</h3>
<p>Ricardo Guimarães (Confidencial Imobiliário) pointe une contradiction fondamentale : le Portugal est à un <strong>record démographique absolu</strong> (plus d''habitants qu''à aucun autre moment de son histoire), mais la dynamique de construction est structurellement inférieure à ce que cette croissance de population devrait générer.</p>
<h3>Les acheteurs étrangers en recul</h3>
<p>Les étrangers ont acheté environ <strong>1 400 logements à Lisbonne en 2025</strong> — le niveau le plus bas depuis 2017. La fin des régimes fiscaux d''attraction (visa dorado, RNH) et la valorisation excessive des biens expliquent ce recul. Le marché reste néanmoins attractif : 64 nationalités représentées, prix moyen de 630 000 €.</p>',
'Chave na Mão · Expresso · 26 juin 2026 · Juliana Simões · Ricardo Guimarães (Confidencial Imobiliário)',
'[{"label": "Prix moyen des transactions T1 2026", "value": "262 939 €"}, {"label": "Acheteurs étrangers à Lisbonne (2025)", "value": "~1 400 transactions"}, {"label": "Prix moyen acheteurs étrangers Lisbonne", "value": "630 000 €"}, {"label": "Capital étranger investi (Lisbonne 2025)", "value": "~880 M€"}]',
1),

(2, 'La garantie publique pour les jeunes acheteurs',
'<p>En 2023, le gouvernement portugais a introduit une garantie publique permettant aux jeunes (jusqu''à 35 ans) d''acheter leur première résidence sans apport personnel. L''État se substitue à la mise de fonds habituellement exigée par les banques (~20 % du prix).</p>
<h3>Le mécanisme</h3>
<p>Sans garantie : l''acheteur apporte 20 % en capital propre. Ce capital est immédiatement amorti — il ne génère pas d''intérêts.</p>
<p>Avec la garantie publique : l''État garantit cette tranche. Les banques financent 100 % du bien. Conséquence directe : <strong>le capital total emprunté est plus élevé</strong>, les mensualités augmentent, et l''exposition au risque de l''emprunteur est structurellement plus grande.</p>
<h3>Les deux problèmes structurels</h3>
<ul>
<li><strong>Risque systémique différé :</strong> en cas de récession ou hausse des taux, des emprunteurs garantis ont des dettes qu''ils n''auraient pas contractées sans la mesure. L''État sera activé comme garant — risque collectif reporté dans le temps.</li>
<li><strong>Demande stimulée sans offre :</strong> la mesure résout l''accès pour une tranche ciblée mais aggrave le déséquilibre fondamental. Stimuler la demande sur un stock insuffisant fait mécaniquement monter les prix.</li>
</ul>
<h3>La position du FMI (juin 2026)</h3>
<p>Le FMI a explicitement alerté sur cette mesure : la garantie publique contribue à <strong>augmenter la demande et à presser davantage les prix</strong>, sans agir sur l''offre. C''est la même critique formulée par l''économiste António Nogueira Leite dès le lancement de la mesure.</p>',
'Chave na Mão · Expresso · 8 mai 2026 · Rita Neves · António Nogueira Leite (économiste)',
'[{"label": "Âge maximum bénéficiaires", "value": "35 ans"}, {"label": "Effet sur les prix (FMI)", "value": "Haussier"}, {"label": "Risque systémique", "value": "Différé"}]',
2),

(2, 'Le crédit immobilier : volumes records et risques croissants',
'<p>Le marché du crédit immobilier portugais a atteint des niveaux records en 2025–2026, alimenté par la baisse de l''Euribor et les mesures publiques d''accès à la propriété.</p>
<h3>Les chiffres du crédit</h3>
<ul>
<li>Mars 2026 : <strong>536 M€ distribués en un seul mois</strong></li>
<li>Total trimestriel : > 2 Md€ — nouveau record historique</li>
<li>Mensualité moyenne remboursée : <strong>424 €/mois</strong></li>
<li>Taux implicite moyen : <strong>un peu plus de 3 %</strong> — plus bas en 3 ans</li>
</ul>
<h3>Les risques identifiés par Morningstar DBRS</h3>
<p>L''agence de notation Morningstar DBRS a alerté sur les risques élevés du crédit immobilier portugais, sans pour autant voir de bulle. Les risques portent sur :</p>
<ul>
<li>La capacité de remboursement des ménages en cas de choc économique</li>
<li>La concentration des nouveaux emprunteurs dans des profils peu capitalisés (garantie publique)</li>
<li>Des durées de prêt très longues (jusqu''à 40 ans) qui chevauchent la retraite</li>
</ul>
<h3>La réponse du Banco de Portugal</h3>
<p>Le régulateur prépare un abaissement du taux d''effort maximum de <strong>50 % à 45 %</strong>, avec passage de recommandation à obligation légale. Conséquence directe : certains ménages qui auraient pu obtenir un crédit ne pourront plus y accéder.</p>',
'Chave na Mão · Expresso · 8 mai 2026 · Rita Neves · António Nogueira Leite + 12 juin 2026 · Juliana Simões · João Pedro Oliveira e Costa (BPI)',
'[{"label": "Crédit distribué en mars 2026", "value": "536 M€"}, {"label": "Total T1 2026", "value": "> 2 Md€"}, {"label": "Mensualité moyenne", "value": "424 €"}, {"label": "Taux d''effort max (nouveau)", "value": "45 %"}]',
3);

-- ─────────────────────────────────────────────────────────────────────────────
-- DONNÉES INITIALES — QUESTIONS (chapitre OFFRE)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO questions (chapter_id, card_id, question, options, correct_index, explanation, difficulty, source) VALUES

(1, 1,
'Quel déficit de logements le Banco de Portugal estime-t-il pour la dernière décennie au Portugal ?',
'["100 000 logements", "200 000 logements", "300 000 logements", "500 000 logements"]',
2,
'Le Banco de Portugal chiffre le déficit accumulé à environ 300 000 logements sur dix ans. 2025 marque le premier solde positif depuis 11 ans — une inversion encore fragile, partiellement due à un ralentissement de l''immigration.',
'medium',
'Chave na Mão · 19 juin 2026 · MMG / Banco de Portugal Bulletin Économique juin 2026'),

(1, 1,
'Selon Manuel Maria Gonçalves (APPII), de combien faudrait-il multiplier la production annuelle de logements pour résoudre le déficit en une décennie ?',
'["Doubler", "Tripler", "Quadrupler", "La maintenir au niveau actuel de 42 000/an"]',
1,
'MMG est explicite : tripler la production est la condition pour résoudre le déficit structurel en dix ans. 42 000 logements licenciés en 2025 est un record depuis 2008 — mais c''est très loin de l''objectif.',
'hard',
'Chave na Mão · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)'),

(1, 2,
'Combien de logements sont identifiés comme bloqués par un déficit de viabilité économique, selon l''APPII ?',
'["12 000", "26 000", "42 000", "59 000"]',
3,
'59 000 logements identifiés comme non viables économiquement — un chiffre reconnu par le gouvernement lui-même. Ces projets existent sur le papier mais ne peuvent pas avancer faute de bouclage financier. La réduction de TVA de 23 % à 6 % vise à débloquer une partie de ce stock.',
'medium',
'Chave na Mão · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)'),

(1, 2,
'Quelle est la position de Manuel Maria Gonçalves sur la réduction de TVA construction de 23 % à 6 % ?',
'["C''est principalement une amélioration des marges des promoteurs", "C''est la différence entre construire ou ne pas construire", "C''est une mesure insuffisante qui n''aura pas d''impact réel", "C''est avant tout un avantage pour les acheteurs finaux"]',
1,
'MMG est catégorique : il ne s''agit pas de marge supplémentaire mais de viabilité économique. Sur un modèle très sensible aux coûts, la réduction peut faire basculer un projet de non-viable à viable. C''est un calcul binaire : construire ou ne pas construire.',
'hard',
'Chave na Mão · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)'),

(1, 3,
'Quelle part du coût total d''un logement neuf représente le foncier au Portugal ?',
'["5 à 10 %", "10 à 15 %", "20 à 35 %", "40 à 50 %"]',
2,
'Le foncier représente entre 20 et 35 % du coût total selon MMG — ce qui explique l''importance stratégique des PPP et de la mobilisation de sols publics par les municipalités. Sans action sur le foncier, il est structurellement impossible de produire du logement abordable dans les zones tendues.',
'medium',
'Chave na Mão · 19 juin 2026 · Juliana Simões · Manuel Maria Gonçalves (APPII)');

-- ─────────────────────────────────────────────────────────────────────────────
-- DONNÉES INITIALES — QUESTIONS (chapitre DEMANDE)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO questions (chapter_id, card_id, question, options, correct_index, explanation, difficulty, source) VALUES

(2, 4,
'Quel était le prix moyen des transactions immobilières au Portugal au T1 2026 ?',
'["218 500 €", "241 300 €", "262 939 €", "287 400 €"]',
2,
'Ricardo Guimarães (Confidencial Imobiliário) confirme un nouveau record historique à 262 939 € en moyenne au T1 2026. Le rythme de croissance ralentit pour la première fois en deux ans, mais les prix continuent de progresser.',
'easy',
'Chave na Mão · 26 juin 2026 · Juliana Simões · Ricardo Guimarães (Confidencial Imobiliário)'),

(2, 4,
'Quel signal Ricardo Guimarães identifie-t-il comme premier marqueur d''un changement de dynamique des prix en 2026 ?',
'["Une baisse absolue des prix dans le centre de Lisbonne", "Un ralentissement du rythme de croissance pour la première fois en deux ans", "Une correction de 5 % sur le marché de l''Algarve", "Un recul du volume de transactions de 12 %"]',
1,
'Les prix ne baissent pas — ils sont à un niveau record. Mais le rythme de progression décélère pour la première fois depuis deux ans. Ce ralentissement est un signal à surveiller, pas une inversion de tendance.',
'medium',
'Chave na Mão · 26 juin 2026 · Juliana Simões · Ricardo Guimarães (Confidencial Imobiliário)'),

(2, 5,
'Pourquoi la garantie publique pour les jeunes augmente-t-elle mécaniquement le risque pour les emprunteurs ?',
'["Elle supprime l''obligation d''assurance emprunteur", "Elle permet d''emprunter la mise de fonds initiale, augmentant le capital total emprunté", "Elle allonge la durée maximale des prêts à 50 ans", "Elle indexe les mensualités sur l''inflation"]',
1,
'Sans garantie, l''emprunteur apporte un capital propre non soumis à intérêts. Avec la garantie, les banques financent ce montant — le capital total emprunté est donc plus élevé, la mensualité plus forte, et l''exposition au risque (chômage, maladie, hausse des taux) plus importante.',
'hard',
'Chave na Mão · 8 mai 2026 · Rita Neves · António Nogueira Leite (économiste)'),

(2, 6,
'Quelle mesure prudentielle le Banco de Portugal a-t-il préparée pour limiter les risques du crédit immobilier ?',
'["Plafonner les prêts à 80 % de la valeur du bien", "Réduire le taux d''effort maximum de 50 % à 45 %", "Interdire les prêts à taux variable sur plus de 20 ans", "Limiter la durée des prêts à 30 ans maximum"]',
1,
'Le Banco de Portugal abaisse le taux d''effort maximal de 50 % à 45 % et souhaite rendre cette recommandation contraignante. Objectif : anticiper les risques dans un cycle de hausse de l''endettement des ménages.',
'medium',
'Chave na Mão · 12 juin 2026 · Juliana Simões · João Pedro Oliveira e Costa (BPI)'),

(2, 6,
'Quel était le volume total de crédit immobilier distribué au T1 2026 au Portugal ?',
'["800 M€", "1,2 Md€", "Plus de 2 Md€", "3,5 Md€"]',
2,
'Le T1 2026 dépasse 2 Md€ de crédit immobilier distribué — nouveau record historique. Mars 2026 seul représente 536 M€. La mensualité moyenne remboursée est de 424 €.',
'easy',
'Chave na Mão · 8 mai 2026 · Rita Neves · António Nogueira Leite'),

-- Questions chapitres financement, fiscalité, acteurs
(3, NULL,
'Quel facteur démographique a contribué au premier solde positif de logements en 2025 au Portugal ?',
'["Une accélération des mises en chantier dans les zones rurales", "Un ralentissement de l''immigration", "Une baisse du taux de formation de nouveaux ménages", "Un retour des émigrants portugais"]',
1,
'Le Banco de Portugal note qu''un ralentissement de l''immigration a temporairement réduit la pression sur la demande, permettant au stock de logements neufs de dépasser pour la première fois la formation nette de ménages. Un signal positif, mais fragile et conjoncturel.',
'hard',
'Chave na Mão · 19 juin 2026 · Juliana Simões · Banco de Portugal Bulletin Économique juin 2026'),

(4, NULL,
'Quel impôt Diana Ralha (Association Lisbonnaise de Propriétaires) identifie-t-elle comme le principal frein à la remise de logements sur le marché locatif ?',
'["IMT (droits de mutation)", "Imposto do Selo", "AIMI (adicional ao IMI)", "IRS sur plus-values"]',
2,
'L''AIMI (surtaxe sur l''IMI pour les patrimoines immobiliers supérieurs à 600 000 €) est qualifié de taxe qui pèse uniquement sur le résidentiel — alors que les sièges de banques ou de grandes surfaces en sont exemptés. Sa suppression est la condition sine qua non du retour de confiance des bailleurs.',
'medium',
'Chave na Mão · 22 mai 2026 · Rita Neves · Diana Ralha (Association Lisbonnaise de Propriétaires)'),

(4, NULL,
'Le paquet fiscal logement publié en 2026 prévoit une réduction de l''IRS sur les revenus locatifs. Quel est le nouveau taux pour les loyers dits "modérés" (plafond 2 300 €) ?',
'["5 %", "10 %", "15 %", "20 %"]',
1,
'La réduction porte de 25 % à 10 % pour les propriétaires mettant leurs biens sur le marché avec des loyers inférieurs à 2 300 €/mois. Diana Ralha nuance : la plupart des petits bailleurs payaient déjà moins de 10 % via des contrats longs. L''impact réel est donc limité.',
'medium',
'Chave na Mão · 22 mai 2026 · Rita Neves · Diana Ralha (ALP)'),

(5, NULL,
'Combien d''agents l''IHRU dispose-t-il pour gérer l''ensemble de ses missions en 2026 ?',
'["142 agents", "349 agents", "520 agents", "1 200 agents"]',
1,
'349 agents pour gérer 16 000 logements en patrimoine propre, les candidatures du Primeiro Direito PRR, le programme PAIR (250 000 bénéficiaires), les concours de logement accessible, et la coordination avec les 308 municipalités du pays. Benjamin Pereira les qualifie de "349 héros".',
'hard',
'Chave na Mão · 29 mai 2026 · Rita Neves · Benjamin Pereira (IHRU)'),

(5, NULL,
'Quel programme d''aide à la rente Benjamin Pereira (IHRU) juge-t-il défaillant et recommande-t-il de supprimer ?',
'["Porta 65", "PAIR", "Primeiro Direito", "PRR Habitação"]',
1,
'Le PAIR (Programme d''Aide Individuelle à la Rente) supposait une interopérabilité entre 4 systèmes informatiques (Sécurité sociale, AT, FCT, IHRU) qui n''a jamais fonctionné. Sur 250 000 bénéficiaires, ~40 000 se retrouvent en situation d''incohérence. Pereira estime que le programme devrait être supprimé.',
'medium',
'Chave na Mão · 29 mai 2026 · Rita Neves · Benjamin Pereira (IHRU)');

-- ─────────────────────────────────────────────────────────────────────────────
-- UTILISATEURS INITIAUX (à remplacer par vrais hash en production)
-- Mot de passe temporaire : Academy2026! (à changer au premier login)
-- ─────────────────────────────────────────────────────────────────────────────
-- NB : les hash bcrypt ci-dessous correspondent à "Academy2026!"
-- Générez de nouveaux hash via l'interface admin après déploiement

INSERT INTO users (name, email, password_hash, role) VALUES
('Jean-Baptiste Cordon', 'jbc@lusonorme.com', '$2a$10$placeholder_hash_JBC', 'admin'),
('Pamella', 'pamella@lusonorme.com', '$2a$10$placeholder_hash_PAM', 'user')
ON CONFLICT (email) DO NOTHING;
