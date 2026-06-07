-- ============================================================
--  română cu drag — Schéma Supabase
--  À exécuter dans l'éditeur SQL de ton projet Supabase
-- ============================================================

-- Leçons Assimil
create table if not exists lessons (
  id          serial primary key,
  number      int not null unique,          -- numéro de la leçon (1-60)
  title_ro    text not null,                -- titre en roumain
  title_fr    text not null,                -- titre en français
  dialogue    jsonb,                        -- [{ ro, fr }]
  grammar     text,                         -- notes de grammaire (markdown)
  completed   boolean default false,
  completed_at timestamptz,
  created_at  timestamptz default now()
);

-- Vocabulaire
create table if not exists words (
  id          serial primary key,
  lesson_id   int references lessons(id) on delete cascade,
  ro          text not null,                -- mot en roumain
  fr          text not null,                -- traduction française
  type        text,                         -- substantiv, verb, adjectiv, adverb…
  gender      text,                         -- m, f, n (pour les substantifs)
  example_ro  text,                         -- phrase exemple
  example_fr  text,
  -- Répétition espacée (algo simple SM-2 light)
  srs_level   int default 0,               -- 0=nouveau, 1-2=en cours, 3+=maîtrisé
  srs_next_review timestamptz default now(),
  created_at  timestamptz default now()
);

-- Sessions de révision (flashcards)
create table if not exists review_sessions (
  id          serial primary key,
  word_id     int references words(id) on delete cascade,
  result      text not null check (result in ('again', 'good', 'easy')),
  reviewed_at timestamptz default now()
);

-- Streak & statistiques journalières
create table if not exists daily_stats (
  id          serial primary key,
  date        date not null unique default current_date,
  words_reviewed  int default 0,
  lessons_done    int default 0,
  xp          int default 0
);

-- ============================================================
-- Données de départ : les 10 premières leçons Assimil
-- (tu pourras en ajouter via l'interface)
-- ============================================================

insert into lessons (number, title_ro, title_fr, dialogue, grammar) values
(1,  'Bună ziua!',           'Bonjour !',                '[{"ro":"Bună ziua!","fr":"Bonjour !"},{"ro":"Bună ziua! Ce mai faceți?","fr":"Bonjour ! Comment allez-vous ?"},{"ro":"Mulțumesc, bine. Dumneavoastră?","fr":"Merci, bien. Et vous ?"},{"ro":"Și eu, mulțumesc.","fr":"Moi aussi, merci."}]', '**Salutations** : *Bună ziua* (jour), *Bună dimineața* (matin), *Bună seara* (soir). Le roumain distingue le tutoiement (*tu*) du vouvoiement (*dumneavoastră*).'),
(2,  'Ce mai faci?',         'Comment vas-tu ?',         '[{"ro":"Salut! Ce mai faci?","fr":"Salut ! Comment vas-tu ?"},{"ro":"Bine, mersi. Tu?","fr":"Bien, merci. Et toi ?"},{"ro":"Și eu bine, mulțumesc.","fr":"Moi aussi bien, merci."}]', '**Tutoiement** : *Ce mai faci ?* (sing.) vs *Ce mai faceți ?* (plur./formel). *Mersi* est familier, *mulțumesc* est standard.'),
(3,  'Cum vă numiți?',       'Comment vous appelez-vous ?', '[{"ro":"Bună ziua! Cum vă numiți?","fr":"Bonjour ! Comment vous appelez-vous ?"},{"ro":"Mă numesc Ana. Dumneavoastră?","fr":"Je m''appelle Ana. Et vous ?"},{"ro":"Eu mă numesc Paul. Îmi pare bine.","fr":"Je m''appelle Paul. Enchanté."},{"ro":"Și mie îmi pare bine.","fr":"Enchanté(e) également."}]', '**Se présenter** : *Mă numesc…* (je m''appelle). *Îmi pare bine* = enchanté(e). Le verbe *a se numi* est réflexif.'),
(4,  'De unde ești?',        'D''où es-tu ?',            '[{"ro":"De unde ești?","fr":"D''où es-tu ?"},{"ro":"Sunt din Franța. Tu?","fr":"Je suis de France. Et toi ?"},{"ro":"Eu sunt din România.","fr":"Je suis de Roumanie."},{"ro":"Vorbești românește?","fr":"Tu parles roumain ?"},{"ro":"Puțin. Învăț.","fr":"Un peu. J''apprends."}]', '**Nationalités** : *din Franța* (de France), *din România* (de Roumanie). *A vorbi* = parler. *A învăța* = apprendre.'),
(5,  'Unde locuiești?',      'Où habites-tu ?',          '[{"ro":"Unde locuiești?","fr":"Où habites-tu ?"},{"ro":"Locuiesc în Paris. Tu?","fr":"J''habite à Paris. Et toi ?"},{"ro":"Eu locuiesc în București.","fr":"Moi j''habite à Bucarest."},{"ro":"București e un oraș frumos!","fr":"Bucarest est une belle ville !"}]', '**A locui** = habiter. Préposition *în* + ville. Adjectif *frumos/frumoasă* = beau/belle.'),
(6,  'Familia mea',          'Ma famille',               '[{"ro":"Ai frați sau surori?","fr":"As-tu des frères ou sœurs ?"},{"ro":"Da, am un frate și o soră.","fr":"Oui, j''ai un frère et une sœur."},{"ro":"Ești căsătorit?","fr":"Es-tu marié ?"},{"ro":"Nu, sunt burlac. Tu?","fr":"Non, je suis célibataire. Et toi ?"}]', '**Famille** : *frate* (frère), *soră* (sœur), *tată* (père), *mamă* (mère). L''article *un/o* (indéfini) correspond au genre.'),
(7,  'Unde este...?',        'Où est... ?',              '[{"ro":"Scuzați-mă, unde este gara?","fr":"Excusez-moi, où est la gare ?"},{"ro":"Mergeți drept înainte.","fr":"Allez tout droit."},{"ro":"Mulțumesc mult!","fr":"Merci beaucoup !"},{"ro":"Cu plăcere!","fr":"Avec plaisir !"}]', '**Directions** : *drept înainte* (tout droit), *la stânga* (à gauche), *la dreapta* (à droite). *Scuzați-mă* = excusez-moi (formel).'),
(8,  'La restaurant',        'Au restaurant',            '[{"ro":"Bună seara! Un loc pentru două persoane.","fr":"Bonsoir ! Une table pour deux."},{"ro":"Ce doriți să mâncați?","fr":"Que souhaitez-vous manger ?"},{"ro":"Aș dori o supă și o friptură.","fr":"Je voudrais une soupe et un rôti."},{"ro":"Poftă bună!","fr":"Bon appétit !"}]', '**Au restaurant** : *a dori* = vouloir/désirer. *Aș dori* = je voudrais (conditionnel). *Poftă bună* = bon appétit.'),
(9,  'Cât costă?',           'Combien ça coûte ?',       '[{"ro":"Cât costă această carte?","fr":"Combien coûte ce livre ?"},{"ro":"Costă cincizeci de lei.","fr":"Ça coûte cinquante lei."},{"ro":"E scump! Aveți ceva mai ieftin?","fr":"C''est cher ! Avez-vous quelque chose de moins cher ?"}]', '**Les prix** : *a costa* = coûter. *scump* = cher, *ieftin* = bon marché. La monnaie roumaine est le *leu* (pl. *lei*).'),
(10, 'Ce vreme e azi?',      'Quel temps fait-il ?',     '[{"ro":"Ce vreme e azi?","fr":"Quel temps fait-il aujourd''hui ?"},{"ro":"E frumos, soare și cald.","fr":"Il fait beau, soleil et chaud."},{"ro":"Mâine va ploua.","fr":"Demain il va pleuvoir."},{"ro":"Nu-mi place ploaia!","fr":"Je n''aime pas la pluie !"}]', '**La météo** : *e frumos* (il fait beau), *plouă* (il pleut), *e frig* (il fait froid). *Mâine* = demain, *azi* = aujourd''hui.');

-- Vocabulaire de base (leçon 1)
insert into words (lesson_id, ro, fr, type, gender) values
(1, 'bună ziua',   'bonjour (l''après-midi)', 'expresie', null),
(1, 'bună dimineața', 'bonjour (le matin)',   'expresie', null),
(1, 'bună seara',  'bonsoir',                  'expresie', null),
(1, 'noapte bună', 'bonne nuit',               'expresie', null),
(1, 'mulțumesc',   'merci',                    'expresie', null),
(1, 'da',          'oui',                      'adverb',   null),
(1, 'nu',          'non / ne pas',             'adverb',   null),
(1, 'bine',        'bien',                     'adverb',   null),
(2, 'salut',       'salut',                    'expresie', null),
(2, 'ce mai faci', 'comment vas-tu ?',         'expresie', null),
(3, 'mă numesc',   'je m''appelle',            'verb',     null),
(3, 'îmi pare bine','enchanté(e)',             'expresie', null),
(4, 'sunt',        'je suis',                  'verb',     null),
(4, 'a vorbi',     'parler',                   'verb',     null),
(4, 'a învăța',    'apprendre',                'verb',     null),
(5, 'a locui',     'habiter',                  'verb',     null),
(5, 'oraș',        'ville',                    'substantiv','n'),
(5, 'frumos',      'beau / belle',             'adjectiv', null),
(6, 'frate',       'frère',                    'substantiv','m'),
(6, 'soră',        'sœur',                     'substantiv','f'),
(6, 'mamă',        'mère',                     'substantiv','f'),
(6, 'tată',        'père',                     'substantiv','m'),
(7, 'unde',        'où',                       'adverb',   null),
(7, 'gară',        'gare',                     'substantiv','f'),
(7, 'stânga',      'gauche',                   'substantiv','f'),
(7, 'dreapta',     'droite',                   'substantiv','f'),
(8, 'a mânca',     'manger',                   'verb',     null),
(8, 'a dori',      'vouloir / désirer',        'verb',     null),
(8, 'supă',        'soupe',                    'substantiv','f'),
(9, 'a costa',     'coûter',                   'verb',     null),
(9, 'scump',       'cher',                     'adjectiv', null),
(9, 'ieftin',      'bon marché',               'adjectiv', null),
(10,'vreme',       'temps (météo)',             'substantiv','f'),
(10,'ploaie',      'pluie',                    'substantiv','f'),
(10,'soare',       'soleil',                   'substantiv','m');
