
SELECT e.event_id,
       e.event_name,
       AVG(part_count) AS avg_num_players
  FROM (
    -- For each session, count participants
    SELECT gs.event_id, COUNT(sp.member_id) AS part_count
      FROM GameSessions gs
      JOIN SessionParticipants sp ON gs.session_id = sp.session_id
     GROUP BY gs.event_id, gs.session_id
  ) AS sub
  JOIN Events e ON sub.event_id = e.event_id
 GROUP BY e.event_id, e.event_name
 ORDER BY e.event_id;
