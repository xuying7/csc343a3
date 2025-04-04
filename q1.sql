-- q1.sql
-- "Find the percentage of club members who have participated in at least one
--  game session at each event (only for events with game sessions)."

SELECT e.event_id,
       e.event_name,
       100.0 * COUNT(DISTINCT sp.member_id) / (SELECT COUNT(*) FROM Members) AS pct_participated
  FROM Events e
  JOIN GameSessions gs ON e.event_id = gs.event_id
  JOIN SessionParticipants sp ON gs.session_id = sp.session_id
 GROUP BY e.event_id, e.event_name
 HAVING COUNT(gs.session_id) > 0  -- ensures we only show events that actually have sessions
 ORDER BY e.event_id;
