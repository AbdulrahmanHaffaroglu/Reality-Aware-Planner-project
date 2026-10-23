CREATE DATABASE IF NOT EXISTS tracker;
use tracker;

CREATE TABLE IF NOT EXISTS users(
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS topics(
    topic_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_user INT NOT NULL,
    topic_name VARCHAR(50) NOT NULL,
    monthly_goal DECIMAL(5, 3) NOT NULL,
    active_flag BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_owner_user
        FOREIGN KEY (owner_user)
        REFERENCES users(user_id),

    CONSTRAINT uq_topic_for_user
        UNIQUE (owner_user, topic_name),

    CHECK (monthly_goal < 24 * 30)
);

CREATE TABLE IF NOT EXISTS weekly_plans(
    weekly_plan_id INT PRIMARY KEY AUTO_INCREMENT,
    topic INT NOT NULL,
    week_start DATE NOT NULL,
    planned_hours DECIMAL(5, 1) NOT NULL,
    minimum_hours DECIMAL(5, 1) NOT NULL,

    CONSTRAINT fk_topic
        FOREIGN KEY (topic)
        REFERENCES topics(topic_id),

    CONSTRAINT uq_week_for_topic
        UNIQUE (topic, week_start),

    CHECK (planned_hours < 24 * 7 AND minimum_hours <= planned_hours),
    CHECK (WEEKDAY(week_start) = 0)
);

CREATE TABLE IF NOT EXISTS daily_logs(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user VARCHAR(50),
    today DATE NOT NULL DEFAULT (CURDATE()),

);