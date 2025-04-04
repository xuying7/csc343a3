-- q2.sql
-- "For each game in the inventory, how many times has it been played in game sessions?"

SELECT bg.title AS board_game,
       COUNT(*) AS times_played
  FROM BoardGames bg
  JOIN Copies c ON bg.game_id = c.game_id
  JOIN GameSessions gs ON c.copy_id = gs.copy_id
 GROUP BY bg.title
 ORDER BY times_played DESC, bg.title;
