CREATE DATABASE IF NOT EXISTS tracker;
use tracker;

CREATE TABLE IF NOT EXISTS users(
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS topics(
    topic_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_name VARCHAR(50) NOT NULL,
    monthly_goal DECIMAL(5, 1) NOT NULL,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_user_id_topics
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT uq_topic_for_user
        UNIQUE (user_id, topic_name),

    CONSTRAINT chk_montly_goal 
        CHECK (0 < monthly_goal AND monthly_goal < 24 * 30)
);

CREATE TABLE IF NOT EXISTS weekly_plans(
    weekly_plan_id INT PRIMARY KEY AUTO_INCREMENT,
    topic_id INT NOT NULL,
    week_start DATE NOT NULL,
    planned_hours DECIMAL(5, 1) NOT NULL,
    minimum_hours DECIMAL(5, 1) NOT NULL,

    CONSTRAINT fk_topic_id_weekly_plans
        FOREIGN KEY (topic_id)
        REFERENCES topics(topic_id),

    CONSTRAINT uq_week_per_topic_per_user
        UNIQUE (topic_id, week_start),

    CONSTRAINT chk_planned_hours 
        CHECK (0 < planned_hours AND planned_hours < 24 * 7),

    CONSTRAINT chk_minimum_hours
        CHECK (planned_hours < minimum_hours),

    CONSTRAINT chk_weekday_monday 
        CHECK (WEEKDAY(week_start) = 0)
);

CREATE TABLE IF NOT EXISTS daily_logs(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    log_date DATE NOT NULL,
    tag VARCHAR(25),
    unkown_flag BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_user_id_logs
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT uq_log_per_user_per_day
        UNIQUE (user_id, log_date)
);

CREATE TABLE IF NOT EXISTS log_entries(
    entry_id INT PRIMARY KEY AUTO_INCREMENT,
    daily_log_id INT NOT NULL,
    topic_id INT NOT NULL,
    entry_minutes INT NOT NULL,

    CONSTRAINT fk_daily_log_id
        FOREIGN KEY(daily_log_id)
        REFERENCES daily_logs(log_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_topic_id_entries
        FOREIGN KEY(topic_id)
        REFERENCES topics(topic_id),
    
    CONSTRAINT uq_entry_per_topic_per_day
        UNIQUE (topic_id, daily_log_id),

    CONSTRAINT chk_minutes
    CHECK (0 <= entry_minutes AND entry_minutes < 24*60)
);

