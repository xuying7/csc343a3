-- q3.sql
-- We interpret "the board game that has been facilitated the most by a single exec"
-- as: find (exec, game) with highest count, then return the game. If there's a tie, we may get multiple.

WITH fac_counts AS (
  SELECT e.member_id,
         m.member_name,
         bg.title AS game_title,
         COUNT(*) AS cnt
    FROM Execs e
    JOIN GameSessions gs ON e.member_id = gs.facilitated_by
    JOIN Copies c        ON gs.copy_id = c.copy_id
    JOIN BoardGames bg   ON c.game_id = bg.game_id
    JOIN Members m       ON e.member_id = m.member_id
  GROUP BY e.member_id, m.member_name, bg.title
)
SELECT game_title
  FROM fac_counts
 WHERE cnt = (
   SELECT MAX(cnt) FROM fac_counts
 )
 ORDER BY game_title;
