
INSERT INTO Members (member_name, email, level_of_study)
VALUES
  ('Josh',       'josh@utoronto.ca',   'Undergraduate'),
  ('Grace',      'grace@utoronto.ca',  'Undergraduate'),
  ('Jason',      'jason@grad.com',       'Graduate'),
  ('Zach',       'zach@alumni.com',      'Alumni'),
  ('Eryka',      'eryka@alumni.com',     'Alumni'),
  ('Jimbo',      'jimbo@utoronto.ca',  'Undergraduate'),
  ('Tawfiq',     'tawfiq@utoronto.ca', 'Undergraduate'),
  ('Evelyn',     'evelyn@utoronto.ca', 'Undergraduate'),
  ('Christian',  'chris@utoronto.ca',  'Graduate'),
  ('Ella',       'ella@utoronto.ca',   'Undergraduate'),
  ('Cameron',    'cam@utoronto.ca',    'Undergraduate'),
  ('Honda',      'honda@utoronto.ca',  'Undergraduate'),
  ('Justin',     'justin@utoronto.ca', 'Undergraduate'),
  ('Ari',        'ari@utoronto.ca',    'Undergraduate'),
  ('Max',        'max@utoronto.ca',    'Undergraduate'),
  ('Akshay',     'akshay@alumni.com',    'Alumni'),
  ('Liam',       'liam@utoronto.ca',   'Undergraduate'),
  ('Sophia',     'sophia@utoronto.ca', 'Graduate');

INSERT INTO Execs (member_id, role, date_assumed)
VALUES
  (3, 'Organizer', '2025-01-10'),  
  (4, 'Treasurer', '2025-01-15'),  
  (5, 'Coordinator', '2025-02-01'),
  (17, 'PR Manager', '2025-03-01');

INSERT INTO BoardGames (title, category, min_players, max_players, publisher, release_year)
VALUES
  ('Blood on the Clocktower', 'Social-deduction', 5, 20, 'The Pandemonium Institute', 2019),
  ('Turing Machine',          'Strategy',         1, 4,  'Scorpion Masqué',          2022),
  ('Cascadia',                'Strategy',         1, 4,  'AEG',                      2021),
  ('Cryptid',                 'Strategy',         3, 5,  'Osprey Games',             2018),
  ('Avalon',                  'Social-deduction', 5, 10, 'Indie Boards & Cards',     2012),
  ('7 Wonders',               'Strategy',         2, 7,  'Repos Production',         2010),

  ('Checkers',                'Strategy',         2, 2,  'Classic Games',            1950);


INSERT INTO Copies (game_id, acquisition_date, condition)
VALUES
  (1, '2025-01-05', 'New'),           
  (2, '2025-02-10', 'Lightly-used'),  
  (3, '2025-02-15', 'New'),          
  (4, '2025-02-15', 'New'),          
  (5, '2025-03-01', 'Worn'),         
  (5, '2025-03-05', 'Lightly-used'), 
  (6, '2025-03-01', 'New'),           
  (6, '2025-03-05', 'New'),           
  (7, '2025-04-01', 'Damaged');       

INSERT INTO Events (event_name, location, event_date)
VALUES
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-05'),
  ('Weekly Boardgame Event',  'BA 1200',      '2025-03-12'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-05'),
  ('Basement Clocktower',     'UC Basement',  '2025-03-12'),
  ('Winter Social',           'BA 3200', '2025-02-27'),
  ('Spring Social',           'BA 3200', '2025-04-10'),
  ('Checkers Tournament',     'BA 2200',      '2025-04-15');


INSERT INTO OrganizingCommittee (event_id, exec_id, is_lead)
VALUES
  (1, 3, TRUE),   
  (1, 5, FALSE),  
  (2, 3, TRUE),   
  (2, 4, FALSE),  
  (3, 4, TRUE),   
  (4, 4, TRUE),   
  (4, 17, FALSE), 

  (5, 5, TRUE),   
  
  (6, 17, TRUE),  

  (7, 3, TRUE);   


INSERT INTO GameSessions (event_id, copy_id, facilitated_by)
VALUES
  
  (1, 2, 5),  
  (1, 7, 3),  

  (2, 3, 5),  
  (2, 5, 3),  
  (2, 8, 4),  
 
  (3, 1, 4), 
  
  (4, 1, 4),  
  
  (6, 9, 17), 
  
  (7, 9, 3);  

INSERT INTO SessionParticipants (session_id, member_id)
VALUES
  
  (1, 5), (1, 1), (1, 2),  
  
  (2, 7), (2, 6), (2, 8), (2, 9), 
  
  (3, 2), (3, 8), (3, 10),        
  (4, 6), (4, 7), (4, 11), (4, 12),

  (5, 13), (5, 14), (5, 15),      

  (6, 3), (6, 6), (6, 7), (6, 8), (6, 12), (6, 16),  

  (7, 3), (7, 6), (7, 7), (7, 8), (7, 12), (7, 16),  

  (8, 10), (8, 11), (8, 17),       

  (9, 1), (9, 2), (9, 3);         