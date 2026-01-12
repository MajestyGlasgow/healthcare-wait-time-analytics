/*                 Healthcare Operations Analysis
                    - KPI & Bottleneck Analysis -
				   Fact Table: patient_visits_clean
*/

--  1. Row Count --
SELECT COUNT(*) AS total_vists
FROM patient_visits_clean;

-- 2. Average Wait Time (Arrival to Triage) by Department --
SELECT
	department,
    ROUND(AVG(wait_triage_minutes), 2) AS avg_wait_triage_minutes
FROM patient_visits_clean
GROUP BY department
ORDER BY avg_wait_triage_minutes DESC;

-- 3. Average Provider Wait Time (Triage to Provider) by Department --
SELECT 
	department,
    ROUND(AVG(wait_provider_minutes), 2) AS avg_wait_provider_minutes
    FROM patient_visits_clean
    GROUP BY department
    ORDER BY avg_wait_provider_minutes DESC;
    
-- 4. Length of Stay by Department --
SELECT
	department,
    ROUND(AVG(LOS_minutes), 2) AS avg_los_minutes
FROM patient_visits_clean
GROUP BY department
ORDER BY avg_los_minutes;

-- 5. SLA Compliance by Department (Percentage of Patients Waiting > 30 minutes) --
SELECT 
	department,
    ROUND(
		SUM(CASE WHEN wait_triage_minutes > 30 THEN 1 ELSE 0 END)
		* 100.0 / COUNT(*) ,
        2 ) AS pct_over_30min
FROM patient_visits_clean
GROUP BY department
ORDER BY pct_over_30min DESC;

-- 6. Daily Patient Volume --
SELECT 
	DATE(arrival_time) AS visit_date,
    COUNT(*) AS daily_volume
FROM patient_visits_clean
GROUP BY visit_date
ORDER BY visit_date;

-- 7. Hourly Volume & Wait Time (Peak Hour Analysis) --
SELECT
	HOUR(arrival_time) AS hour_of_day,
    COUNT(*) AS visit_count,
    ROUND(AVG(wait_triage_minutes), 2) AS avg_wait_triage_minutes
FROM patient_visits_clean
GROUP BY hour_of_day
ORDER BY visit_count DESC;

--  8. Monthly Volume & Wait Time (Seasonality ) --
SELECT
	DATE_FORMAT(arrival_time, '%Y-%m') AS year_mon , 
    COUNT(*) AS monthly_visits,
    ROUND(AVG(wait_triage_minutes), 2) AS avg_wait_triage_minutes
FROM patient_visits_clean
GROUP BY year_mon
ORDER BY year_mon;

-- 9. Staffing vs Wait TIME (Operational Load) --
SELECT
	nurses_on_shift,
    ROUND(AVG(wait_triage_minutes), 2) AS avg_wait_triage_minutes
FROM patient_visits_clean
GROUP BY nurses_on_shift
ORDER BY nurses_on_shift;
    
SELECT 
	providers_on_shift,
    ROUND(AVG(wait_provider_minutes), 2) AS avg_wait_provider_minutes
FROM patient_visits_clean
GROUP BY providers_on_shift
ORDER BY providers_on_shift;

-- 10. Acuity-Based Wait Time Comparison --
SELECT
	acuity_level,
    COUNT(*) AS visits,
    ROUND(AVG(wait_triage_minutes), 2) AS avg_wait_triage_minutes
FROM patient_visits_clean
GROUP BY acuity_level
ORDER BY avg_wait_triage_minutes DESC;

-- 11. Department Contribution to Long Waits (>30 minutes) --

WITH dept_waits AS (
	SELECT
		department,
        COUNT(*) AS total_visits,
        SUM(CASE WHEN wait_triage_minutes > 30 THEN 1 ELSE 0 END) AS long_wait_visits
	FROM patient_visits_clean
    GROUP BY department
),
dept_percentages AS (
	SELECT
		department,
        total_visits,
        long_wait_visits,
        ROUND(long_wait_visits * 100.0 / total_visits, 2) AS pct_long_waits,
        ROUND(
			long_wait_visits * 100.0 / SUM(long_wait_visits) OVER ()
            , 2) AS contribution_to_total_long_waits
	FROM dept_waits
)
SELECT
	department,
    total_visits,
    long_wait_visits,
    pct_long_waits,
    contribution_to_total_long_waits,
    SUM(contribution_to_total_long_waits) 
		OVER (ORDER BY contribution_to_total_long_waits DESC) AS cumulative_contribution
FROM dept_percentages 
ORDER BY contribution_to_total_long_waits DESC;

    

    




        





