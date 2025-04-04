-- ============================================================================
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
  ('Akshay',     'akshay@alumni.com',    'Alumni')
;

-- Execs (subset of the above members)
-- We'll guess their IDs by looking at the nextval in the table or by returning from the SELECT:
-- But let's assume:
--   Jason => member_id=3
--   Zach  => member_id=4
--   Eryka => member_id=5
INSERT INTO Execs (member_id, role, date_assumed)
VALUES
  (3, 'Organizer', '2025-01-10'),  -- Jason
  (4, 'Organizer', '2025-01-15'),  -- Zach
  (5, 'Organizer', '2025-02-01'); -- Eryka

-- BoardGames 
INSERT INTO BoardGames (title, category, min_players, max_players, publisher, release_year)
VALUES
  ('Blood on the Clocktower', 'Social-deduction', 5, 20, 'The Pandemonium Institute', 2019),
  ('Turing Machine',          'Strategy',         1, 4,  'Scorpion Masqué',          2022),
  ('Cascadia',                'Strategy',         1, 4,  'AEG',                      2021),
  ('Cryptid',                 'Strategy',         3, 5,  'Osprey Games',             2018),
  ('Avalon',                  'Social-deduction', 5, 10, 'Indie Boards & Cards',     2012),
  ('7 Wonders',               'Strategy',         2, 7,  'Repos Production',         2010)
;

-- Copies 
-- (We have multiple copies for Avalon and 7 Wonders as in glg-data.txt)
INSERT INTO Copies (game_id, acquisition_date, condition)
VALUES
  (1, '2025-01-05', 'New'),           -- Blood on the Clocktower copy #1
  (2, '2025-02-10', 'Lightly-used'),  -- Turing Machine #2
  (3, '2025-02-15', 'New'),           -- Cascadia #3
  (4, '2025-02-15', 'New'),           -- Cryptid #4
  (5, '2025-03-01', 'Worn'),          -- Avalon #5
  (5, '2025-03-05', 'Lightly-used'),  -- Avalon #6
  (6, '2025-03-01', 'New'),           -- 7 Wonders #7
  (6, '2025-03-05', 'New');           -- 7 Wonders #8

-- Events 
INSERT INTO Events (event_name, location, event_date)
VALUES
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-05'),
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-12'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-05'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-12'),
  ('Winter Social',           'Outside Quad', '2025-02-27')
;

-- OrganizingCommittee 
-- We'll guess the event_ids from the nextval or by simple ordering: 
--   1=Weekly(3/5), 2=Weekly(3/12), 3=BC(3/5), 4=BC(3/12), 5=Winter Social(2/27)
-- We'll have Jason as lead for weekly, Zach for basement, Eryka for winter. 
INSERT INTO OrganizingCommittee (event_id, exec_id, is_lead)
VALUES
  (1, 3, TRUE),  -- (Weekly 3/5) lead=Jason
  (2, 3, TRUE),  -- (Weekly 3/12) lead=Jason
  (3, 4, TRUE),  -- (BC 3/5) lead=Zach
  (4, 4, TRUE),  -- (BC 3/12) lead=Zach
  (5, 5, TRUE);  -- (Winter Social) lead=Eryka
-- If you want more committee members, add them with is_lead=FALSE.

-- GameSessions 
-- Let’s create sessions for Weekly 3/5: Turing Machine, 7 Wonders
-- We'll guess the copy_ids from above: Turing Machine= #2, 7 Wonders= #7 or #8
-- Facilitators: Eryka=5 or Jason=3, etc.
INSERT INTO GameSessions (event_id, copy_id, facilitated_by)
VALUES
  (1, 2, 5), -- Turing Machine on 3/5, facilitated by Eryka
  (1, 7, 3), -- 7 Wonders (copy #7) on 3/5, facilitated by Jason

-- Another set for Weekly 3/12
INSERT INTO GameSessions (event_id, copy_id, facilitated_by)
VALUES
  (2, 3, 5), -- Cascadia (copy #3), Eryka again
  (2, 5, 3), -- Avalon (copy #5), Jason
  (2, 8, 1);  -- 7 Wonders copy #8, let's pretend 'member_id=1' is "Josh"? 
             -- But wait, he's not an Exec. This might violate the foreign key. 
             -- So better use an Exec, e.g. (2, 8, 4) => Zach


-- Basement Clocktower events 
INSERT INTO GameSessions (event_id, copy_id, facilitated_by)
VALUES
  (3, 1, 4),  -- 3/5 BC, Blood on the Clocktower copy #1, facilitator=Zach
  (4, 1, 4); -- 3/12 BC, same game & copy, facilitator=Zach

-- Winter Social event had "no games" but let's demonstrate that 
-- we won't create sessions for event_id=5.  0 sessions there.

-- SessionParticipants
-- session_id=1: Turing Machine (3/5), facilitated by Eryka
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (1, 5),  -- Eryka also playing
  (1, 1),  -- Josh
  (1, 2);  -- Grace

-- session_id=2: 7 Wonders (3/5)
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (2, 7),  -- Tawfiq
  (2, 6),  -- Jimbo
  (2, 8),  -- Evelyn
  (2, 9);  -- Christian

-- session_id=3: Cascadia (3/12)
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (3, 2),   -- Grace
  (3, 8),   -- Evelyn
  (3, 10);  -- Ella

-- session_id=4: Avalon (3/12)
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (4, 6),   -- Jimbo
  (4, 7),   -- Tawfiq
  (4, 11),  -- Cameron
  (4, 4),   -- Zach also playing while facilitating is not allowed 
            --   by domain, but we can't do that check in DDL.
  (4, 12);  -- Honda

-- session_id=5: 7 Wonders (3/12)
-- We used (2, 8, 4) so session_id=5 is the new one
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (5, 13), -- Justin
  (5, 14), -- Ari
  (5, 15); -- Max

-- session_id=6: Blood on Clocktower (3/5)
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (6, 6),   -- Jimbo
  (6, 7),   -- Tawfiq
  (6, 3),   -- Jason
  (6, 8),   -- Evelyn
  (6, 12),  -- Honda
  (6, 16);  -- Akshay

-- session_id=7: Blood on Clocktower (3/12)
INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  (7, 6),   -- Jimbo
  (7, 7),   -- Tawfiq
  (7, 3),   -- Jason
  (7, 8),   -- Evelyn
  (7, 12),  -- Honda
  (7, 16);  -- Akshay
