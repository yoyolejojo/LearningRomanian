# română cu drag 🇷🇴

> Ton carnet d'apprentissage du roumain — basé sur la méthode Assimil

## Stack

- **Astro 4** — framework
- **Netlify** — déploiement (SSR)
- **Supabase** — base de données PostgreSQL (free tier)

---

## 1. Créer le projet Supabase

1. Va sur [supabase.com](https://supabase.com) et crée un nouveau projet
2. Dans **SQL Editor**, colle et exécute le contenu de `supabase-schema.sql`
   - Cela crée les tables `lessons`, `words`, `review_sessions`, `daily_stats`
   - Et insère les 10 premières leçons Assimil + 35 mots de base

3. Va dans **Settings → API** et copie :
   - **Project URL** → `PUBLIC_SUPABASE_URL`
   - **anon public key** → `PUBLIC_SUPABASE_ANON_KEY`

---

## 2. Variables d'environnement

```bash
cp .env.example .env
# Remplis avec tes valeurs Supabase
```

---

## 3. Développement local

```bash
npm install
npm run dev
# → http://localhost:4321
```

---

## 4. Déploiement Netlify

### Option A — Interface Netlify (recommandé)
1. Push le projet sur GitHub
2. Sur [netlify.com](https://netlify.com) → **Add new site → Import from Git**
3. **Build command** : `npm run build`
4. **Publish directory** : `dist`
5. Dans **Environment variables**, ajoute tes deux variables Supabase
6. Deploy !

### Option B — Netlify CLI
```bash
npm install -g netlify-cli
netlify login
netlify init
netlify env:set PUBLIC_SUPABASE_URL "https://xxx.supabase.co"
netlify env:set PUBLIC_SUPABASE_ANON_KEY "eyJ..."
netlify deploy --prod
```

---

## Structure du projet

```
src/
├── layouts/
│   └── Layout.astro          # Layout principal (nav + styles)
├── pages/
│   ├── index.astro           # Dashboard (accueil)
│   ├── lessons/
│   │   ├── index.astro       # Liste des leçons
│   │   └── [number].astro    # Page d'une leçon
│   ├── vocabulary/
│   │   └── index.astro       # Vocabulaire avec filtres
│   ├── flashcards/
│   │   └── index.astro       # Flashcards (répétition espacée)
│   └── exercises/
│       └── index.astro       # QCM interactif
├── styles/
│   └── global.css            # Design tokens + styles globaux
└── lib/
    └── supabase.js           # Client Supabase
```

---

## Ajouter des leçons

Via l'interface SQL Supabase ou en ajoutant des lignes dans la table `lessons` :

```sql
insert into lessons (number, title_ro, title_fr, dialogue, grammar)
values (
  11,
  'La piață',
  'Au marché',
  '[{"ro":"Cât costă merele?","fr":"Combien coûtent les pommes ?"},...]',
  '**A cumpăra** = acheter...'
);
```

---

## Fonctionnalités

| Page | Fonctionnalité |
|------|----------------|
| Accueil | Dashboard, mot du jour, streak, progression globale |
| Leçons | Liste Assimil, dialogue bilingue, notes de grammaire, marquer complétée |
| Vocabulaire | Table filtrée par leçon/type/recherche, niveau SRS |
| Flashcards | Répétition espacée (SRS simplifié), boutons Revoir/Bien/Facile |
| Exercices | QCM interactif sur le vocabulaire appris |
