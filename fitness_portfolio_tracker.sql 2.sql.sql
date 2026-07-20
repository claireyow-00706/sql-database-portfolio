-- 1. Create a fresh sandbox database
CREATE DATABASE IF NOT EXISTS analytics_sandbox;
USE analytics_sandbox;

-- 2. Create a clean table for daily activity tracking
CREATE TABLE IF NOT EXISTS  daily_metrics (
    log_date DATE PRIMARY KEY,
    step_count INT,
    workout_completed VARCHAR(50),
    active_calories_burned INT,
    sleep_hours DECIMAL(3,1)
);

-- 3. Populate it with real-world sample data
INSERT INTO daily_metrics (log_date, step_count, workout_completed, active_calories_burned, sleep_hours) VALUES
('2026-07-01', 12500, 'Lower Body Strength', 450, 7.5),
('2026-07-02', 14200, 'None', 150, 6.8),
('2026-07-03', 9800, 'Upper Body Hypertrophy', 400, 8.0),
('2026-07-04', 11000, 'None', 120, 7.2),
('2026-07-05', 13500, 'Core & Cardio', 380, 6.5),
('2026-07-06', 8500, 'None', 90, 7.8),
('2026-07-07', 12100, 'Full Body Conditioning', 420, 7.0);

-- 4. Basic filtering and verification queries
SELECT * FROM daily_metrics; 

SELECT 
  log_date AS date_recorded,
  step_count,
  workout_completed
FROM daily_metrics
WHERE step_count >= 11000
  AND workout_completed <> 'None'
ORDER BY step_count DESC; 

SELECT * FROM daily_metrics
WHERE step_count < 12000
   OR sleep_hours < 7.0
ORDER BY sleep_hours ASC; 

SELECT log_date, workout_completed
FROM daily_metrics
WHERE workout_completed IN ('Lower Body Strength', 'Upper Body Hypertrophy'); 

SELECT log_date, step_count
FROM daily_metrics
WHERE step_count BETWEEN 10000 AND 13000;

SELECT log_date, workout_completed
FROM daily_metrics
WHERE workout_completed LIKE '%Body%';

-- Fixed the OR shortcut syntax error here
SELECT * FROM daily_metrics
WHERE step_count BETWEEN 10000 AND 14000
  AND (workout_completed LIKE '%Body%' OR workout_completed LIKE '%Cardio%')
ORDER BY log_date DESC;

-- 5. Aggregation and Grouping
SELECT 
   COUNT(*) AS total_days_tracked,
   AVG(step_count) AS average_daily_steps,
   SUM(active_calories_burned) AS total_calories_burned
FROM daily_metrics; 

SELECT 
    workout_completed,
    COUNT(*) AS number_of_days,
    AVG(step_count) AS avg_steps
FROM daily_metrics
GROUP BY workout_completed;

SELECT workout_completed, AVG(step_count) AS avg_steps
FROM daily_metrics
GROUP BY workout_completed
HAVING avg_steps > 10000;

SELECT workout_completed, AVG(sleep_hours) AS avg_sleep_hours
FROM daily_metrics
GROUP BY workout_completed 
HAVING avg_sleep_hours > 7.0;

-- 6. Secondary Table Setup
CREATE TABLE IF NOT EXISTS purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    purchase_date DATE, 
    item_name VARCHAR(100),
    category VARCHAR(40),
    amount_spent DECIMAL(6,2)
);

INSERT INTO purchases (purchase_date, item_name, category, amount_spent) VALUES
('2026-07-01', 'Grass-Fed Whey Protein', 'Fitness', 85.00),
('2026-07-03', 'Unsalted Butter & Almond Flour', 'Baking', 24.50),
('2026-07-05', 'Pre-Workout Powder', 'Fitness', 45.00),
('2026-07-08', 'New Baking Muffin Pan', 'Baking', 35.00);

-- 7. Relational Joins
SELECT  
  m.log_date,
  m.workout_completed,
  p.item_name,
  p.amount_spent
FROM daily_metrics AS m
INNER JOIN purchases AS p
  ON m.log_date = p.purchase_date; 

-- Explicit long-form naming check
SELECT 
  daily_metrics.log_date, 
  daily_metrics.workout_completed, 
  purchases.item_name
FROM daily_metrics
INNER JOIN purchases 
  ON daily_metrics.log_date = purchases.purchase_date;

-- Left Join analysis
SELECT 
  m.log_date,
  m.workout_completed,
  p.item_name,
  p.amount_spent
FROM daily_metrics AS m
LEFT JOIN purchases AS p
  ON m.log_date = p.purchase_date
ORDER BY m.log_date ASC; 

-- 8. Logical Control (Case When Challenge)
SELECT 
    log_date,
    sleep_hours,
    CASE 
        WHEN sleep_hours >= 7.5 THEN 'Optimal'
        ELSE 'Inadequate'
    END AS sleep_quality
FROM daily_metrics;

SELECT 
log_date,
sleep_hours,
CASE WHEN sleep_hours >= 8.0 THEN 'Excellent'
     WHEN sleep_hours >= 7.0 THEN 'Moderate'
END AS sleep_performance 
FROM analytics_sandbox.daily_metrics;

SELECT 
COUNT(*) AS total_days_tracked, 
COUNT(CASE WHEN step_count >= 12000 THEN 1 END) AS high_step_days,
COUNT(CASE WHEN workout_completed <> 'None' THEN 1 END) AS active_workout_days
FROM analytics_sandbox.daily_metrics;

SELECT 
daily_metrics.log_date,
daily_metrics.step_count,
CASE WHEN step_count >= 13000 THEN 'Elite Tier'
     WHEN step_count BETWEEN 10000 AND 12999 THEN 'Target Met'
     ELSE 'Base Activity'
END AS step_tier 
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
workout_completed, 
active_calories_burned,
AVG(active_calories_burned) OVER() AS global_avg_calories
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
workout_completed,
active_calories_burned,
AVG(active_calories_burned) OVER(PARTITION BY workout_completed) AS category_avg_calories
FROM analytics_sandbox.daily_metrics;

SELECT  
log_date,
step_count,
SUM(step_count) OVER(ORDER BY log_date) AS cumulative_steps
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
active_calories_burned,
AVG(active_calories_burned) OVER() AS overall_avg_burn,
active_calories_burned - AVG(active_calories_burned) OVER() AS variance
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
workout_completed,
active_calories_burned,
AVG(active_calories_burned) OVER(PARTITION BY workout_completed) AS group_avg_burn 
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
step_count,
SUM(step_count) OVER (ORDER BY log_date) AS rolling_total_steps
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
step_count,
workout_completed,
SUM(step_count) OVER(PARTITION BY workout_completed ORDER BY log_date)
FROM analytics_sandbox.daily_metrics;


SELECT 
log_date,
active_calories_burned,
MAX(active_calories_burned) OVER() AS max_cals_burned
FROM analytics_sandbox.daily_metrics;

-- rank (leaves gaps in ranking)
SELECT 
log_date,
active_calories_burned,
RANK() OVER(ORDER BY avtive_calories_burned DESC) AS calorie_rank
FROM analytics_sandbox.daily_metrics;

-- dense style (no gaps in ranking)
SELECT 
log_date,
active_calories_burned,
DENSE RANK() OVER(ORDER BY active_calories_burned DESC) AS calorie_dense_rank
FROM analytics_sandbox.daily_metrics;

SELECT 
log_date,
active_calories_burned,
workout_completed,
DENSE_RANK() OVER(PARTITION BY workout_completed ORDER BY log_date)
FROM analytics_sandbox.daily_metrics;

-- 1. the nested box approach 
SELECT log_date,active_calories_burned
FROM ( 
     -- Inner Query: generates the leaderboard first
     SELECT log_date,active_calories_burned,
            DENSE_RANK() OVER(ORDER BY active_calories_burned DESC) AS calorie_rank
     FROM analytics_sandbox.daily_metrics
) AS ranked_table -- need to give the inner box a nickname. 
WHERE calorie_rank = 1; 


-- 2. first creates the leaderboard which is also the same as the nested query in 1.(This is a neater method as compared to 1)
WITH ranked_metrics_cte AS (
SELECT log_date, active_calories_burned,
DENSE_RANK() OVER(ORDER BY active_calories_burned DESC) AS calorie_rank
FROM analytics_sandbox.daily_metrics
)

-- 3. use the above (2) as a table 
SELECT log_date, active_calories_burned
FROM ranked_metrics_cte
WHERE calorie_rank =1;

-- A) define the leaderboard for use in B
WITH workout_streaks AS (
SELECT 
log_date, 
active_calories_burned, 
workout_completed,
DENSE_RANK() OVER(PARTITION BY workout_completed ORDER BY log_date) AS day_streak_number
FROM analytics_sandbox.daily_metrics
)

-- B) use A to filter out results
SELECT log_date, workout_completed, day_streak_number
FROM workout_streaks
WHERE day_streak_number = 1;


-- A: to build multi-chain CTE, step 1, filter down to intense days
WITH high_intensity_days AS (
SELECT log_date, workout_completed, active_calories_burned
FROM analytics_sandbox.daily_metrics
WHERE active_calories_burned >= 400
),

-- B: step 2, rank only those intense days (querying from A)
ranked_days AS (
SELECT 
log_date,
workout_completed,
active_calories_burned,
ROW_NUMBER() OVER(ORDER BY active_calories_burned DESC) AS performance_rank
FROM high_intensity_days
)

-- C: step 3, output the final leaderboard
SELECT performance_rank, log_date, workout_completed,active_calories_burned
FROM ranked_days
WHERE performance_rank <= 3;

WITH high_step_days AS (
SELECT log_date, workout_completed, step_count
FROM analytics_sandbox.daily_metrics
WHERE step_count >= 12000
),

ranked_steps AS (
SELECT
log_date,
workout_completed,
step_count,
ROW_NUMBER() OVER(ORDER BY step_count DESC) AS step_rank
FROM high_step_days 
)

SELECT step_rank, log_date, workout_completed
FROM ranked_steps
WHERE step_rank = 1;


CREATE TABLE workout_details(
workout_name VARCHAR(40)PRIMARY KEY,
trainer_name VARCHAR(40),
equipment_needed VARCHAR(40)
);

INSERT INTO workout_details VALUES ('Strength Training','Coach Alex','Barbell');
INSERT INTO workout_details VALUES ('Running','Coach Sarah','None');

SELECT
m.log_date,
m.workout_completed,
m.active_calories_burned,
d.trainer_name,
d.workout_name
FROM analytics_sandbox.daily_metrics AS m
LEFT JOIN workout_details AS d
ON m.workout_completed = d.workout_name;

SELECT 
d.trainer_name,
COUNT(m.log_date) AS total_sessions_coached,
AVG(m.active_calories_burned) AS avg_cal_burned
FROM analytics_sandbox.daily_metrics AS m
INNER JOIN workout_details AS d
ON m.workout_completed = d.workout_name
GROUP BY d.trainer_name; 

SELECT 
m.log_date,
m.workout_completed,
d.equipment_needed
FROM analytics_sandbox.daily_metrics AS m
INNER JOIN workout_details AS d
ON m.workout_completed = d.workout_name; 


SELECT 
log_date,
active_calories_burned,
CASE WHEN active_calories_burned >= 400 THEN 'High Intensity'
     WHEN active_calories_burned <= 250 THEN 'Moderate Intensity'
     ELSE 'Light/Rest Day'
END AS workout_intensity
FROM analytics_sandbox.daily_metrics;


SELECT 
m.log_date,
m.workout_completed,
COALESCE(d.trainer_name,'No Coach/Self-Guided') AS trainer_name
FROM analytics_sandbox.daily_metrics AS m
LEFT JOIN workout_details AS d
ON m.workout_completed = d.workout_name;


SELECT 
log_date,
step_count,
CASE WHEN step_count >= 10000 THEN 'Goal Met'
     ELSE 'Below Target'
END AS step_status
FROM analytics_sandbox.daily_metrics;

SELECT
m.log_date,
m.workout_completed,
COALESCE(d.trainer_name, 'Self-Guided') AS trainer_assigned,
CASE WHEN step_count >= 12000 THEN 'High Activity'
     WHEN step_count >= 8000 THEN 'Moderate Activity'
     ELSE 'Rest/Recovery'
END AS activity_tier 
FROM analytics_sandbox.daily_metrics AS m
LEFT JOIN workout_details AS d 
ON m.workout_completed = d.workout_name;

WITH cleaned_metrics AS (
    SELECT 
        m.log_date,
        m.workout_completed,
        m.step_count,
        COALESCE(d.trainer_name, 'Self-Guided') AS trainer_assigned,
        CASE 
            WHEN m.step_count >= 12000 THEN 'High Activity'
            WHEN m.step_count >= 8000  THEN 'Moderate Activity'
            ELSE 'Rest / Recovery'
        END AS activity_tier
    FROM analytics_sandbox.daily_metrics AS m
    INNER JOIN workout_details AS d
        ON m.workout_completed = d.workout_name
),

ranked_tiers AS (
    SELECT 
        log_date,
        workout_completed,
        step_count,
        trainer_assigned,
        activity_tier,
        ROW_NUMBER() OVER (
            PARTITION BY activity_tier 
            ORDER BY step_count DESC
        ) AS tier_rank
    FROM cleaned_metrics
) -- ✅ No comma here before the final SELECT!

SELECT 
    activity_tier, 
    tier_rank, 
    log_date, 
    workout_completed, 
    trainer_assigned, 
    step_count
FROM ranked_tiers
WHERE tier_rank = 1;

-- creating the inner query
SELECT log_date, workout_completed, active_calories_burned
FROM analytics_sandbox.daily_metrics
WHERE active_calories_burned > 300;

WITH high_calories_day AS (
SELECT log_date, workout_completed, active_calories_burned
FROM analytics_sandbox.daily_metrics
WHERE active_calories_burned > 300
)
SELECT 
workout_completed,
COUNT(log_date) AS times_performed
FROM high_calories_day 
GROUP BY workout_completed;

WITH heavy_workouts AS (
SELECT workout_completed, active_calories_burned
FROM analytics_sandbox.daily_metrics
)
SELECT 
workout_completed,
active_calories_burned
FROM heavy_workouts 
WHERE active_calories_burned < 450;

WITH cleaned_schedule AS (
SELECT 
m.log_date,
m.workout_completed,
COALESCE(d.trainer_name, 'Self-Guided') AS trainer_name
FROM analytics_sandbox.daily_metrics AS m
LEFT JOIN workout_details AS d 
ON m.workout_completed = d.workout_name
)
SELECT 
m.log_date,
m.workout_completed,
trainer_name
FROM cleaned_schedule 
WHERE trainer_name = 'Self-Guided';

WITH workout_totals AS (
SELECT
workout_completed,
SUM(active_calories_burned) AS total_calories,
COUNT(log_date) AS total_sessions
FROM analytics_sandbox.daily_metrics
GROUP BY workout_completed
)
SELECT 
workout_completed,
total_calories
FROM workout_totals
WHERE total_calories > 500;

-- CTE #1: filter down to active days only
WITH active_days AS (
SELECT 
log_date,
workout_completed,
active_calories_burned
FROM analytics_sandbox.daily_metrics
WHERE workout_completed <> 'Rest Day'
),
-- CTE #2: calculate calorie tier on those active days, working within the first CTE
tiered_days AS (
SELECT
log_date,
workout_completed,
active_calories_burned,
CASE WHEN active_calories_burned >= 400 THEN 'Burner'
     ELSE 'Steady'
END AS calorie_tier
FROM active_days
)
SELECT *
FROM tiered_days 
WHERE calorie_tier = 'Burner';

-- practice #1 CTE 
WITH high_burns AS (
SELECT
log_date,
workout_completed,
active_calories_burned
FROM analytics_sandbox.daily_metrics
WHERE active_calories_burned >= 300
)
SELECT 
log_date,
workout_completed,
active_calories_burned
FROM high_burns;

-- practice #2 CTE
WITH coach_stats AS (
    SELECT 
        d.trainer_name,                           
        AVG(m.active_calories_burned) AS avg_cals
    FROM analytics_sandbox.daily_metrics AS m
    LEFT JOIN workout_details AS d                
        ON m.workout_completed = d.workout_name
    GROUP BY d.trainer_name                    
)
SELECT
    trainer_name,
    avg_cals
FROM coach_stats
WHERE avg_cals >= 250;

-- practice #3 CTE
WITH activity_log AS (
SELECT 
log_date,
step_count,
workout_completed
FROM analytics_sandbox.daily_metrics 
WHERE workout_completed = 'Rest Day'
),
goal_logs AS (
SELECT 
log_date,
step_count,
workout_completed
FROM activity_log 
WHERE step_count >= 10000
)
SELECT * FROM goal_logs; 
