
WITH counts AS (
    SELECT m.member_id,
           m.member_name,
           COUNT(DISTINCT sp.session_id) AS num_sessions
      FROM Members m
      JOIN SessionParticipants sp ON m.member_id = sp.member_id
     GROUP BY m.member_id
)
SELECT member_name, num_sessions
  FROM counts
 WHERE num_sessions = (SELECT MAX(num_sessions) FROM counts);
