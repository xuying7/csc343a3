-- data.sql
-- Inserts sample data for Gotta Love Games schema
-- ============================================================================

-- Members (everyone)
INSERT INTO Members (member_name, email, level_of_study)
VALUES
  ('Josh',       'josh@somewhere.com',   'Undergraduate'),
  ('Grace',      'grace@somewhere.com',  'Undergraduate'),
  ('Jason',      'jason@grad.com',       'Graduate'),
  ('Zach',       'zach@alumni.com',      'Alumni'),
  ('Eryka',      'eryka@alumni.com',     'Alumni'),
  ('Jimbo',      'jimbo@somewhere.com',  'Undergraduate'),
  ('Tawfiq',     'tawfiq@somewhere.com', 'Undergraduate'),
  ('Evelyn',     'evelyn@somewhere.com', 'Undergraduate'),
  ('Christian',  'chris@somewhere.com',  'Graduate'),
  ('Ella',       'ella@somewhere.com',   'Undergraduate'),
  ('Cameron',    'cam@somewhere.com',    'Undergraduate'),
  ('Honda',      'honda@somewhere.com',  'Undergraduate'),
  ('Justin',     'justin@somewhere.com', 'Undergraduate'),
  ('Ari',        'ari@somewhere.com',    'Undergraduate'),
  ('Max',        'max@somewhere.com',    'Undergraduate'),
  ('Akshay',     'akshay@alumni.com',    'Alumni'),
  -- Additional members to test edge cases
  ('Liam',       'liam@somewhere.com',   'Undergraduate'),
  ('Sophia',     'sophia@somewhere.com', 'Graduate');

-- Execs (subset of members)
INSERT INTO Execs (member_id, role, date_assumed)
VALUES
  (3, 'Organizer', '2025-01-10'),  -- Jason
  (4, 'Treasurer', '2025-01-15'),  -- Zach
  (5, 'Coordinator', '2025-02-01'),-- Eryka
  (17, 'PR Manager', '2025-03-01');-- Liam (new exec)

-- BoardGames 
INSERT INTO BoardGames (title, category, min_players, max_players, publisher, release_year)
VALUES
  ('Blood on the Clocktower', 'Social-deduction', 5, 20, 'The Pandemonium Institute', 2019),
  ('Turing Machine',          'Strategy',         1, 4,  'Scorpion Masqué',          2022),
  ('Cascadia',                'Strategy',         1, 4,  'AEG',                      2021),
  ('Cryptid',                 'Strategy',         3, 5,  'Osprey Games',             2018),
  ('Avalon',                  'Social-deduction', 5, 10, 'Indie Boards & Cards',     2012),
  ('7 Wonders',               'Strategy',         2, 7,  'Repos Production',         2010),
  -- Additional game to test min=max players
  ('Checkers',                'Strategy',         2, 2,  'Classic Games',            1950);

-- Copies 
INSERT INTO Copies (game_id, acquisition_date, condition)
VALUES
  (1, '2025-01-05', 'New'),           -- Blood on the Clocktower
  (2, '2025-02-10', 'Lightly-used'),  -- Turing Machine
  (3, '2025-02-15', 'New'),           -- Cascadia
  (4, '2025-02-15', 'New'),           -- Cryptid
  (5, '2025-03-01', 'Worn'),          -- Avalon
  (5, '2025-03-05', 'Lightly-used'),  -- Avalon
  (6, '2025-03-01', 'New'),           -- 7 Wonders
  (6, '2025-03-05', 'New'),           -- 7 Wonders
  (7, '2025-04-01', 'Damaged');       -- Checkers (damaged copy)

-- Events 
INSERT INTO Events (event_name, location, event_date)
VALUES
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-05'),
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-12'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-05'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-12'),
  ('Winter Social',           'Outside Quad', '2025-02-27'),
  -- Additional events for testing
  ('Spring Social',           'Outside Quad', '2025-04-10'),
  ('Checkers Tournament',     'BA 2200',      '2025-04-15');

-- OrganizingCommittee 
-- Assign multiple execs per event, with one lead each
INSERT INTO OrganizingCommittee (event_id, exec_id, is_lead)
VALUES
  -- Weekly 3/5 (event_id=1)
  (1, 3, TRUE),   -- Jason (lead)
  (1, 5, FALSE),  -- Eryka
  -- Weekly 3/12 (event_id=2)
  (2, 3, TRUE),   -- Jason (lead)
  (2, 4, FALSE),  -- Zach
  -- Basement Clocktower 3/5 (event_id=3)
  (3, 4, TRUE),   -- Zach (lead)
  -- Basement Clocktower 3/12 (event_id=4)
  (4, 4, TRUE),   -- Zach (lead)
  (4, 17, FALSE), -- Liam
  -- Winter Social (event_id=5)
  (5, 5, TRUE),   -- Eryka (lead)
  -- Spring Social (event_id=6)
  (6, 17, TRUE),  -- Liam (lead)
  -- Checkers Tournament (event_id=7)
  (7, 3, TRUE);   -- Jason (lead)

-- GameSessions 
-- Ensure facilitators are execs and no time overlaps
INSERT INTO GameSessions (event_id, copy_id, facilitated_by)
VALUES
  -- Weekly 3/5 (event_id=1)
  (1, 2, 5),  -- Turing Machine (Eryka)
  (1, 7, 3),  -- 7 Wonders (Jason)
  -- Weekly 3/12 (event_id=2)
  (2, 3, 5),  -- Cascadia (Eryka)
  (2, 5, 3),  -- Avalon (Jason)
  (2, 8, 4),  -- 7 Wonders (Zach)
  -- Basement Clocktower 3/5 (event_id=3)
  (3, 1, 4),  -- Blood on the Clocktower (Zach)
  -- Basement Clocktower 3/12 (event_id=4)
  (4, 1, 4),  -- Blood on the Clocktower (Zach)
  -- Spring Social (event_id=6)
  (6, 9, 17), -- Checkers (Liam facilitates damaged copy)
  -- Checkers Tournament (event_id=7)
  (7, 9, 3);  -- Checkers (Jason)

-- SessionParticipants
-- Avoid members in multiple sessions on the same date
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  -- Session 1 (Turing Machine, 3/5)
  (1, 5), (1, 1), (1, 2),  -- Eryka, Josh, Grace
  -- Session 2 (7 Wonders, 3/5)
  (2, 7), (2, 6), (2, 8), (2, 9),  -- Tawfiq, Jimbo, Evelyn, Christian
  -- Session 3 (Cascadia, 3/12)
  (3, 2), (3, 8), (3, 10),         -- Grace, Evelyn, Ella
  -- Session 4 (Avalon, 3/12)
  (4, 6), (4, 7), (4, 11), (4, 12),-- Jimbo, Tawfiq, Cameron, Honda
  -- Session 5 (7 Wonders, 3/12)
  (5, 13), (5, 14), (5, 15),       -- Justin, Ari, Max
  -- Session 6 (Blood on Clocktower, 3/5)
  (6, 3), (6, 6), (6, 7), (6, 8), (6, 12), (6, 16),  -- Jason, Jimbo, Tawfiq, Evelyn, Honda, Akshay
  -- Session 7 (Blood on Clocktower, 3/12)
  (7, 3), (7, 6), (7, 7), (7, 8), (7, 12), (7, 16),  -- Jason, Jimbo, Tawfiq, Evelyn, Honda, Akshay
  -- Session 8 (Checkers, 4/10)
  (8, 10), (8, 11), (8, 17),       -- Ella, Cameron, Liam (exec but not facilitating)
  -- Session 9 (Checkers, 4/15)
  (9, 1), (9, 2), (9, 3);          -- Josh, Grace, Jason (exec facilitating but allowed to play same game)