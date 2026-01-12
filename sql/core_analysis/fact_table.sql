CREATE TABLE patient_visits_clean (
	visit_id INT AUTO_INCREMENT PRIMARY KEY, 
	arrival_time DATETIME NOT NULL,
    triage_time DATETIME NOT NULL,
    provider_time DATETIME NOT NULL,
    discharge_time DATETIME NOT NULL,
    department VARCHAR(50) NOT NULL,
    acuity_level varchar(20) NOT NULL,
    nurses_on_shift INT NOT NULL,
    providers_on_shift INT NOT NULL,
    wait_triage_minutes DECIMAL(6,2) generated always AS (
		timestampdiff(SECOND, arrival_time, triage_time) / 60 
        ) STORED, 
	wait_provider_minutes DECIMAL(6, 2) generated always AS (
		timestampdiff(SECOND, triage_time, provider_time) / 60
        ) STORED,
	LOS_minutes DECIMAL(6,2) generated always AS (
		timestampdiff(SECOND, arrival_time, discharge_time) / 60
        ) STORED
);

    
    