SET SERVEROUTPUT ON;

---------------------------------------------------
-- 1) FUNCTIONS
---------------------------------------------------

------------------------------------------
-- Válida ser o valor é menor que zero
------------------------------------------
CREATE OR REPLACE FUNCTION gs_validate_positive_number (p_value NUMBER) RETURN VARCHAR2 IS
BEGIN

  IF p_value < 0 THEN
    RETURN 'Digite um valor válido!';
  ELSE
    RETURN 'Valor válido';
  END IF;
  
END gs_validate_positive_number;

SELECT gs_validate_positive_number(8) FROM DUAL;  
SELECT gs_validate_positive_number(-5) FROM DUAL; 


------------------------------------------
-- Válida o email
------------------------------------------
CREATE OR REPLACE FUNCTION gs_validate_email_format (p_email VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
    RETURN 'E-mail válido';
    
  ELSE
    RETURN 'E-mail inválido';
  END IF;
  
END gs_validate_email_format;
/
SELECT gs_validate_email_format('teste@dominio.com') FROM DUAL;  
SELECT gs_validate_email_format('teste@dominio') FROM DUAL;     

------------------------------------------
-- Calcular o Score de Risco
------------------------------------------
CREATE OR REPLACE FUNCTION gs_calculate_risk_score (
  p_work_hours NUMBER,
  p_meetings NUMBER,
  p_limit_hours NUMBER,
  p_limit_meetings NUMBER
) RETURN NUMBER IS
  v_risk_score NUMBER;
BEGIN
 
  v_risk_score := (p_work_hours / p_limit_hours) * 0.5 + (p_meetings / p_limit_meetings) * 0.5;
  
  RETURN v_risk_score;
END gs_calculate_risk_score;
/

SELECT gs_calculate_risk_score(9, 4, 8, 3) FROM DUAL; 

---------------------------------------------------
-- 2) PROCEDURES
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT ROLES
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_role (p_role_name VARCHAR2) IS
BEGIN
  INSERT INTO GS_ROLE (ROLE_NAME)
  VALUES (p_role_name);
  COMMIT;
END gs_insert_role;
/


CREATE OR REPLACE PROCEDURE insert_limits (
  p_limit_hours NUMBER,
  p_limit_meetings NUMBER
) IS
BEGIN
  INSERT INTO GS_LIMITS (LIMIT_HOURS, LIMIT_MEETINGS, CREATED_AT)
  VALUES (p_limit_hours, p_limit_meetings, SYSDATE);
  COMMIT;
END insert_limits;
/
---------------------------------------------------
-- INSERT ROLE
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT LIMITS
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_limits (
  p_limit_hours NUMBER,
  p_limit_meetings NUMBER
) IS
BEGIN

  INSERT INTO GS_LIMITS (LIMIT_HOURS, LIMIT_MEETINGS, CREATED_AT)
  VALUES (p_limit_hours, p_limit_meetings, SYSDATE);
  
  COMMIT;
END gs_insert_limits;
/

---------------------------------------------------
-- INSERT LIMITS
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT STATUS RISK
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_status_risk (p_status_name VARCHAR2) IS
BEGIN

  INSERT INTO GS_STATUS_RISK (STATUS_NAME_RISK)
  VALUES (p_status_name);
  
  COMMIT;
  
END gs_insert_status_risk;
/
---------------------------------------------------
-- INSERT STATUS RISK
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT USERS
---------------------------------------------------

CREATE OR REPLACE PROCEDURE gs_insert_user (
  p_name_user VARCHAR2,
  p_email_user VARCHAR2,
  p_password_user VARCHAR2,
  p_status CHAR,
  p_id_role NUMBER,
  p_id_limits NUMBER
) IS
  v_email_status VARCHAR2(100);
BEGIN

  v_email_status := gs_validate_email_format(p_email_user);
  
  
  IF v_email_status != 'E-mail válido' THEN
    RAISE_APPLICATION_ERROR(-20001, 'E-mail inválido!');
  END IF;


  INSERT INTO GS_USERS (NAME_USER, EMAIL_USER, PASSWORD_USER, STATUS, ID_ROLE, ID_LIMITS)
  VALUES (p_name_user, p_email_user, p_password_user, p_status, p_id_role, p_id_limits);

  COMMIT;
END gs_insert_user;
/

---------------------------------------------------
-- INSERT USERS
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT BEHAVIOR DATA
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_behavior_data (
  p_avg_typing_speed FLOAT,
  p_clicks_per_min NUMBER,
  p_avg_touch_pressure FLOAT,
  p_avg_touch_duration FLOAT,
  p_double_click_rate NUMBER,
  p_date_log DATE,
  p_session_duration DATE,
  p_id_user NUMBER
) IS
BEGIN
  
  INSERT INTO GS_BEHAVIOR_DATA (AVG_TYPING_SPEED, CLICKS_PER_MIN, AVG_TOUCH_PRESSURE, AVG_TOUCH_DURATION, 
                                DOUBLE_CLICK_RATE, DATE_LOG, SESSION_DURATION, ID_USER)
  VALUES (p_avg_typing_speed, p_clicks_per_min, p_avg_touch_pressure, p_avg_touch_duration, 
          p_double_click_rate, p_date_log, p_session_duration, p_id_user);

  COMMIT;
  
END gs_insert_behavior_data;
/

---------------------------------------------------
-- INSERT BEHAVIOR DATA
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE DAILY LOG
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_daily_log (
  p_work_hours NUMBER,
  p_meetings NUMBER,
  p_log_date DATE,
  p_id_user NUMBER
) IS
BEGIN
 
  INSERT INTO GS_DAILY_LOGS (WORK_HOURS, MEETINGS, LOG_DATE, ID_USER)
  VALUES (p_work_hours, p_meetings, p_log_date, p_id_user);
  
  COMMIT;
  
END gs_insert_daily_log;
/
---------------------------------------------------
-- INSERT DAILY LOG
---------------------------------------------------


---------------------------------------------------
-- PROCEDURE INSERT SCORES
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_score (
  p_date_score DATE,
  p_work_hours NUMBER,
  p_meetings NUMBER,
  p_id_status_risk NUMBER,
  p_id_user NUMBER,
  p_id_log NUMBER
) IS
  v_score_value NUMBER;
BEGIN
 
  v_score_value := gs_calculate_risk_score(p_work_hours, p_meetings, 8, 3); 


  INSERT INTO GS_SCORES (DATE_SCORE, SCORE_VALUE, TIME_RECOMMENDATION, CREATED_AT, ID_STATUS_RISK, ID_USER, ID_LOG)
  VALUES (p_date_score, v_score_value, 10, SYSDATE, p_id_status_risk, p_id_user, p_id_log);

  COMMIT;
END gs_insert_score;
/

---------------------------------------------------
-- INSERT SCORES
---------------------------------------------------

---------------------------------------------------
-- PROCEDURE INSERT PREDICTION
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_prediction (
  p_stress_predicted FLOAT,
  p_message VARCHAR2,
  p_date_predicted DATE,
  p_id_user NUMBER,
  p_id_scores NUMBER,
  p_id_status_risk NUMBER
) IS
BEGIN

  INSERT INTO GS_PREDICTIONS (STRESS_PREDICTED, MESSAGE, DATE_PREDICTED, ID_USER, ID_SCORES, ID_STATUS_RISK)
  VALUES (p_stress_predicted, p_message, p_date_predicted, p_id_user, p_id_scores, p_id_status_risk);
  
  COMMIT;
  
END gs_insert_prediction;
/

---------------------------------------------------
-- INSERT PREDICTION
---------------------------------------------------





