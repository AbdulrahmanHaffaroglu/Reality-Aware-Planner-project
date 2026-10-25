USE tracker;

-- Reset (children first)
DELETE FROM log_entries;
DELETE FROM daily_logs;
DELETE FROM weekly_plans;
DELETE FROM topics;
DELETE FROM users;

-- Users
INSERT INTO users (username) VALUES ('me'), ('sara');

-- Topics (Gym will have a plan but zero logged minutes)
INSERT INTO topics (user_id, topic_name, monthly_goal)
SELECT user_id, 'SQL', 20 FROM users WHERE username = 'me';
INSERT INTO topics (user_id, topic_name, monthly_goal)
SELECT user_id, 'NumPy', 15 FROM users WHERE username = 'me';
INSERT INTO topics (user_id, topic_name, monthly_goal)
SELECT user_id, 'Gym', 12 FROM users WHERE username = 'me';
INSERT INTO topics (user_id, topic_name, monthly_goal)
SELECT user_id, 'Spanish', 10 FROM users WHERE username = 'sara';

-- Weekly plans for 'me': two different Mondays
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
SELECT t.topic_id, v.week_start, v.planned, v.min_h
FROM (
    SELECT 'SQL' AS name, '2026-10-12' AS week_start, 5 AS planned, 2 AS min_h
    UNION ALL SELECT 'NumPy', '2026-10-12', 4, 2
    UNION ALL SELECT 'Gym',   '2026-10-12', 3, 1
    UNION ALL SELECT 'SQL',   '2026-10-19', 5, 2
    UNION ALL SELECT 'NumPy', '2026-10-19', 4, 2
    UNION ALL SELECT 'Gym',   '2026-10-19', 3, 1
) v
JOIN users u  ON u.username = 'me'
JOIN topics t ON t.user_id = u.user_id AND t.topic_name = v.name;

-- Weekly plan for 'sara'
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
SELECT t.topic_id, '2026-10-19', 3, 1
FROM topics t JOIN users u ON u.user_id = t.user_id
WHERE u.username = 'sara' AND t.topic_name = 'Spanish';

-- Daily logs for 'me'.
-- 2026-10-22 is deliberately missing (a gap);
-- 2026-10-24 is logged as "unknown".
INSERT INTO daily_logs (user_id, log_date, tag, unknown_flag)
SELECT u.user_id, v.d, v.tag, v.unk
FROM (
    SELECT '2026-10-12' AS d, 'good day' AS tag, FALSE AS unk
    UNION ALL SELECT '2026-10-13', 'slacked',  FALSE
    UNION ALL SELECT '2026-10-19', 'good day', FALSE
    UNION ALL SELECT '2026-10-20', 'tired',    FALSE
    UNION ALL SELECT '2026-10-21', 'went out', FALSE
    UNION ALL SELECT '2026-10-23', 'good day', FALSE
    UNION ALL SELECT '2026-10-24', 'unknown',  TRUE
) v
JOIN users u ON u.username = 'me';

-- Daily log for 'sara'
INSERT INTO daily_logs (user_id, log_date, tag)
SELECT user_id, '2026-10-19', 'good day' FROM users WHERE username = 'sara';

-- Log entries for 'me' (some topics skipped on some days; none for Gym)
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
SELECT dl.log_id, t.topic_id, v.mins
FROM (
    SELECT '2026-10-12' AS d, 'SQL' AS name, 60 AS mins
    UNION ALL SELECT '2026-10-12', 'NumPy', 45
    UNION ALL SELECT '2026-10-19', 'SQL',   90
    UNION ALL SELECT '2026-10-19', 'NumPy', 60
    UNION ALL SELECT '2026-10-20', 'SQL',   30
    UNION ALL SELECT '2026-10-23', 'SQL',  120
    UNION ALL SELECT '2026-10-23', 'NumPy', 75
) v
JOIN users u       ON u.username = 'me'
JOIN daily_logs dl ON dl.user_id = u.user_id AND dl.log_date = v.d
JOIN topics t      ON t.user_id = u.user_id AND t.topic_name = v.name;

-- Entries for 'sara'
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
SELECT dl.log_id, t.topic_id, 50
FROM users u
JOIN daily_logs dl ON dl.user_id = u.user_id AND dl.log_date = '2026-10-19'
JOIN topics t      ON t.user_id = u.user_id AND t.topic_name = 'Spanish'
WHERE u.username = 'sara';

-- Sanity checks
SELECT * FROM users;
SELECT * FROM topics;
SELECT * FROM weekly_plans;
SELECT * FROM daily_logs;
SELECT * FROM log_entries;