USE tracker;

-- Helper variables (run these lines together first)
SET @me      = (SELECT user_id FROM users WHERE username = 'me');
SET @sql_t   = (SELECT topic_id FROM topics WHERE user_id = @me AND topic_name = 'SQL');
SET @gym_t   = (SELECT topic_id FROM topics WHERE user_id = @me AND topic_name = 'Gym');
SET @log_19  = (SELECT log_id FROM daily_logs WHERE user_id = @me AND log_date = '2026-10-19');
SELECT @me, @sql_t, @gym_t, @log_19;   -- none of these should be NULL

-- 1. should FAIL (duplicate): same topic twice in the same daily log
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (@log_19, @sql_t, 10);

-- 2. should FAIL (check): negative minutes
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (@log_19, @gym_t, -5);

-- 3. should FAIL (check): more minutes than a day has
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (@log_19, @gym_t, 9000);

-- 4. should FAIL (foreign key): topic that doesn't exist
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (@log_19, 99999, 30);

-- 5. should FAIL (foreign key): daily log that doesn't exist
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (99999, @sql_t, 30);

-- 6. should FAIL (check): week_start is a Tuesday
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
VALUES (@sql_t, '2026-10-27', 5, 2);

-- 7. should FAIL (check): minimum bigger than planned
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
VALUES (@sql_t, '2026-10-26', 2, 5);

-- 8. should FAIL (duplicate): second plan for same topic and week
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
VALUES (@sql_t, '2026-10-19', 6, 2);

-- 9. should FAIL (duplicate): second daily log for same user and date
INSERT INTO daily_logs (user_id, log_date, tag)
VALUES (@me, '2026-10-19', 'tired');

-- 10. should FAIL (duplicate): same topic name twice for the same user
INSERT INTO topics (user_id, topic_name, monthly_goal)
VALUES (@me, 'SQL', 10);

-- 11. should FAIL (duplicate): duplicate username
INSERT INTO users (username) VALUES ('me');

-- 12. should FAIL (foreign key): topic owned by a user that doesn't exist
INSERT INTO topics (user_id, topic_name, monthly_goal)
VALUES (99999, 'Ghost', 10);

-- 13. should FAIL (check): zero goal
INSERT INTO topics (user_id, topic_name, monthly_goal)
VALUES (@me, 'Zero', 0);

-- 14. should FAIL (check): negative minimum hours
INSERT INTO weekly_plans (topic_id, week_start, planned_hours, minimum_hours)
VALUES (@sql_t, '2026-10-26', 5, -1);

-- 15. should SUCCEED: goal of 100 hours (tests the DECIMAL size)
INSERT INTO topics (user_id, topic_name, monthly_goal)
VALUES (@me, 'BigGoal', 100);

-- 16. should SUCCEED: CASCADE delete
INSERT INTO daily_logs (user_id, log_date, tag) VALUES (@me, '2026-11-01', 'test');
SET @tmp_log = LAST_INSERT_ID();
INSERT INTO log_entries (daily_log_id, topic_id, entry_minutes)
VALUES (@tmp_log, @sql_t, 20);
DELETE FROM daily_logs WHERE log_id = @tmp_log;
SELECT COUNT(*) AS should_be_zero FROM log_entries WHERE daily_log_id = @tmp_log;

-- Cleanup after test 15
DELETE FROM topics WHERE topic_name = 'BigGoal';