CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Hancock'), ('Harrison', 'Ford'),
  ('Harry', 'Potter'), ('Luke', 'Skywalker'), ('Ozzy', 'Osbourne');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('First!', 'Does the Narwhal Bacon?', (SELECT id FROM users WHERE fname = 'Ozzy')),
  ('Second!', 'Do you have Stairs in your House?', (SELECT id FROM users WHERE fname = 'Luke'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'First!'),
    (SELECT id FROM users WHERE fname = 'Ozzy')),
  ((SELECT id FROM questions WHERE title = 'First!'),
    (SELECT id FROM users WHERE fname = 'Harry')),
  ((SELECT id FROM questions WHERE title = 'Second!'),
    (SELECT id FROM users WHERE fname = 'Ozzy')),
  ((SELECT id FROM questions WHERE title = 'First!'),
    (SELECT id FROM users WHERE fname = 'Luke'));

INSERT INTO
  replies (body, question_id, parent_id, user_id)
VALUES
  ('That is a stupid question!',
    (SELECT id FROM questions WHERE title = 'First!'),
    NULL,
    (SELECT id FROM users WHERE fname = 'Harry'));

INSERT INTO
  replies (body, question_id, parent_id, user_id)
VALUES
  ('Rule 34',
    (SELECT id FROM questions WHERE title = 'First!'),
    (SELECT id FROM replies WHERE body = 'That is a stupid question!'),
    (SELECT id FROM users WHERE fname = 'Luke'));

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Second!'),
   (SELECT id FROM users WHERE fname = 'John')),
  ((SELECT id FROM questions WHERE title = 'First!'),
   (SELECT id FROM users WHERE fname = 'Ozzy'));
