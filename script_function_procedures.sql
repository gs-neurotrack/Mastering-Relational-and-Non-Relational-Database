--GS-BANCO-NEUROTRACK
SET SERVEROUTPUT ON;

---------------------------------------------------
-- 1) FUNCTIONS
---------------------------------------------------

------------------------------------------
-- Válida se o valor é menor que zero
------------------------------------------
CREATE OR REPLACE FUNCTION gs_validate_positive_number (p_value NUMBER) 
RETURN VARCHAR2 IS
BEGIN
  IF p_value < 0 THEN
    RETURN 'Digite um valor válido!';
  ELSE
    RETURN 'Valor válido';
  END IF;
END gs_validate_positive_number;
/

SELECT gs_validate_positive_number(8) FROM DUAL;  
SELECT gs_validate_positive_number(-5) FROM DUAL; 


------------------------------------------
-- Válida o email
------------------------------------------
CREATE OR REPLACE FUNCTION gs_validate_email_format (p_email VARCHAR2) 
RETURN VARCHAR2 IS
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
  p_work_hours      NUMBER,
  p_meetings        NUMBER,
  p_limit_hours     NUMBER,
  p_limit_meetings  NUMBER
) RETURN NUMBER IS
  v_risk_score NUMBER;
BEGIN
  v_risk_score := (p_work_hours / p_limit_hours) * 0.5
                + (p_meetings   / p_limit_meetings) * 0.5;
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
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_role: ' || SQLERRM);
END gs_insert_role;
/

--------------------------------------------------
-- TESTE EXCEPTION ROLE
--------------------------------------------------
EXEC gs_insert_role('NOME_DE_ROLE_GRANDE_DEMAIS_123');



---------------------------------------------------
-- INSERT ROLE
---------------------------------------------------
EXEC gs_insert_role('ADMIN');
EXEC gs_insert_role('USER');
EXEC gs_insert_role('GESTOR');
EXEC gs_insert_role('ANALISTA');
EXEC gs_insert_role('DESENVOLVEDOR');
EXEC gs_insert_role('SUPORTE');
EXEC gs_insert_role('COORDENADOR');
EXEC gs_insert_role('ESTAGIARIO');
EXEC gs_insert_role('DIRETOR');
EXEC gs_insert_role('CEO');
EXEC gs_insert_role('COLABORADOR');

SELECT * FROM GS_ROLE;


---------------------------------------------------
-- PROCEDURE INSERT LIMITS
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_limits (
  p_limit_hours     NUMBER,
  p_limit_meetings  NUMBER
) IS
BEGIN
  INSERT INTO GS_LIMITS (LIMIT_HOURS, LIMIT_MEETINGS, CREATED_AT)
  VALUES (p_limit_hours, p_limit_meetings, SYSDATE);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_limits: ' || SQLERRM);
END gs_insert_limits;
/

--------------------------------------------------
-- TESTE EXCEPTION ROLE
--------------------------------------------------
EXEC gs_insert_limits(NULL, 3);


---------------------------------------------------
-- INSERT LIMITS
---------------------------------------------------
EXEC gs_insert_limits(8, 3);  
EXEC gs_insert_limits(6, 2);  
EXEC gs_insert_limits(9, 4);  
EXEC gs_insert_limits(7, 3); 
EXEC gs_insert_limits(6, 3);  
EXEC gs_insert_limits(8, 5);  
EXEC gs_insert_limits(10, 2); 
EXEC gs_insert_limits(5, 1);  
EXEC gs_insert_limits(8, 2); 
EXEC gs_insert_limits(7, 4);  

SELECT * FROM GS_LIMITS;


---------------------------------------------------
-- PROCEDURE INSERT STATUS RISK
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_status_risk (p_status_name VARCHAR2) IS
BEGIN
  INSERT INTO GS_STATUS_RISK (STATUS_NAME_RISK)
  VALUES (p_status_name);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_status_risk: ' || SQLERRM);
END gs_insert_status_risk;
/

--------------------------------------------------
-- TESTE EXCEPTION LIMITS
--------------------------------------------------
EXEC gs_insert_status_risk('STATUS_CARACTERES_MUITO_LONGOS_123456789');


---------------------------------------------------
-- INSERT STATUS RISK
---------------------------------------------------
EXEC gs_insert_status_risk('SAUDÁVEL');
EXEC gs_insert_status_risk('MODERADO');
EXEC gs_insert_status_risk('ALTO');
EXEC gs_insert_status_risk('CRÍTICO');
EXEC gs_insert_status_risk('BAIXO');
EXEC gs_insert_status_risk('EM ALERTA');
EXEC gs_insert_status_risk('URGENTE');
EXEC gs_insert_status_risk('NORMAL');
EXEC gs_insert_status_risk('ESTÁVEL');
EXEC gs_insert_status_risk('GRAVE');

SELECT * FROM GS_STATUS_RISK;


---------------------------------------------------
-- PROCEDURE INSERT USERS
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_user (
  p_name_user      VARCHAR2,
  p_email_user     VARCHAR2,
  p_password_user  VARCHAR2,
  p_status         CHAR,
  p_id_role        NUMBER,
  p_id_limits      NUMBER
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
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_user: ' || SQLERRM);
END gs_insert_user;
/

--------------------------------------------------
-- TESTE EXCEPTION USERS
--------------------------------------------------
EXEC gs_insert_user('Joao','email_invalido','123','A',1,1);


---------------------------------------------------
-- INSERT USERS
---------------------------------------------------
EXEC gs_insert_user('Melissa Maia', 'melissa.maia@empresa.com', 'senha123', 'A', 1, 1);
EXEC gs_insert_user('Maria Souza', 'maria@empresa.com', 'senha456', 'A', 2, 2);
EXEC gs_insert_user('João Silva', 'joao@empresa.com', 'senha789', 'A', 1, 3);
EXEC gs_insert_user('Ana Costa', 'ana@empresa.com', 'senha101', 'A', 2, 4);
EXEC gs_insert_user('Carlos Lima', 'carlos@empresa.com', 'senha112', 'A', 1, 5);
EXEC gs_insert_user('Juliana Oliveira', 'juliana@empresa.com', 'senha314', 'A', 3, 1);
EXEC gs_insert_user('Ricardo Almeida', 'ricardo@empresa.com', 'senha415', 'A', 4, 2);
EXEC gs_insert_user('Fernanda Costa', 'fernanda@empresa.com', 'senha516', 'A', 1, 3);
EXEC gs_insert_user('Lucas Pereira', 'lucas@empresa.com', 'senha617', 'A', 5, 4);
EXEC gs_insert_user('Beatriz Martins', 'beatriz@empresa.com', 'senha718', 'A', 2, 5);

SELECT * FROM GS_USERS;


---------------------------------------------------
-- PROCEDURE DAILY LOG
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_daily_log (
  p_work_hours  NUMBER,
  p_meetings    NUMBER,
  p_log_date    DATE,
  p_id_user     NUMBER
) IS
BEGIN
  INSERT INTO GS_DAILY_LOGS (WORK_HOURS, MEETINGS, LOG_DATE, ID_USER)
  VALUES (p_work_hours, p_meetings, p_log_date, p_id_user);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_daily_log: ' || SQLERRM);
END gs_insert_daily_log;
/

--------------------------------------------------
-- TESTE EXCEPTION DAILY_LOG
--------------------------------------------------
EXEC gs_insert_daily_log(8, 3, SYSDATE, 999);


---------------------------------------------------
-- INSERT DAILY LOG
---------------------------------------------------
EXEC gs_insert_daily_log(8, 4, SYSDATE, 1);
EXEC gs_insert_daily_log(6, 3, SYSDATE, 2);
EXEC gs_insert_daily_log(9, 5, SYSDATE, 3);
EXEC gs_insert_daily_log(7, 4, SYSDATE, 4);
EXEC gs_insert_daily_log(6, 2, SYSDATE, 5);
EXEC gs_insert_daily_log(8, 3, SYSDATE, 6);
EXEC gs_insert_daily_log(10, 4, SYSDATE, 7);
EXEC gs_insert_daily_log(5, 2, SYSDATE, 8);
EXEC gs_insert_daily_log(7, 3, SYSDATE, 9);
EXEC gs_insert_daily_log(6, 4, SYSDATE, 10);

SELECT * FROM GS_DAILY_LOGS;


---------------------------------------------------
-- PROCEDURE INSERT SCORES
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_score (
  p_date_score       DATE,
  p_work_hours       NUMBER,
  p_meetings         NUMBER,
  p_id_status_risk   NUMBER,
  p_id_user          NUMBER,
  p_id_log           NUMBER
) IS
  v_score_value NUMBER;
BEGIN
  -- Aqui usei limites fixos (8h / 3 reuniões), como no seu exemplo
  v_score_value := gs_calculate_risk_score(p_work_hours, p_meetings, 8, 3); 

  INSERT INTO GS_SCORES (
    DATE_SCORE, SCORE_VALUE, TIME_RECOMMENDATION, CREATED_AT, 
    ID_STATUS_RISK, ID_USER, ID_LOG
  )
  VALUES (
    p_date_score, v_score_value, 10, SYSDATE,
    p_id_status_risk, p_id_user, p_id_log
  );

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_score: ' || SQLERRM);
END gs_insert_score;
/

--------------------------------------------------
-- TESTE EXCEPTION SOCORES
--------------------------------------------------
EXEC gs_insert_score(SYSDATE, 8, 4, 1, 1, 999);




---------------------------------------------------
-- INSERT SCORES
---------------------------------------------------
EXEC gs_insert_score(SYSDATE, 8, 4, 1, 24, 11);  
EXEC gs_insert_score(SYSDATE, 6, 3, 2, 2, 2); 
EXEC gs_insert_score(SYSDATE, 9, 5, 3, 3, 3);  
EXEC gs_insert_score(SYSDATE, 7, 4, 1, 4, 4);  
EXEC gs_insert_score(SYSDATE, 6, 2, 2, 5, 5); 
EXEC gs_insert_score(SYSDATE, 8, 4, 3, 6, 6); 
EXEC gs_insert_score(SYSDATE, 7, 3, 1, 7, 7); 
EXEC gs_insert_score(SYSDATE, 6, 3, 2, 8, 8); 
EXEC gs_insert_score(SYSDATE, 9, 5, 3, 9, 9);  
EXEC gs_insert_score(SYSDATE, 6, 4, 2, 10, 10);

SELECT * FROM GS_SCORES;


---------------------------------------------------
-- PROCEDURE INSERT PREDICTION
---------------------------------------------------
CREATE OR REPLACE PROCEDURE gs_insert_prediction (
  p_stress_predicted  FLOAT,
  p_message           VARCHAR2,
  p_date_predicted    DATE,
  p_id_user           NUMBER,
  p_id_scores         NUMBER,
  p_id_status_risk    NUMBER
) IS
BEGIN
  INSERT INTO GS_PREDICTIONS (
    STRESS_PREDICTED, MESSAGE, DATE_PREDICTED, 
    ID_USER, ID_SCORES, ID_STATUS_RISK
  )
  VALUES (
    p_stress_predicted, p_message, p_date_predicted,
    p_id_user, p_id_scores, p_id_status_risk
  );
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erro na procedure gs_insert_prediction: ' || SQLERRM);
END gs_insert_prediction;
/

--------------------------------------------------
-- TESTE EXCEPTION PREDICTION
--------------------------------------------------
EXEC gs_insert_prediction(1.2, 'Erro', SYSDATE, 999, 1, 1);


---------------------------------------------------
-- INSERT PREDICTION
---------------------------------------------------
EXEC gs_insert_prediction(1, 'Risco Moderado', SYSDATE, 24, 23, 2);
EXEC gs_insert_prediction(0.85, 'Risco Baixo', SYSDATE, 2, 2, 1);
EXEC gs_insert_prediction(1.35, 'Risco Alto', SYSDATE, 3, 3, 3);
EXEC gs_insert_prediction(1.50, 'Risco Crítico', SYSDATE, 4, 4, 4);
EXEC gs_insert_prediction(0.75, 'Risco Baixo', SYSDATE, 5, 5, 1);
EXEC gs_insert_prediction(1.20, 'Risco Moderado', SYSDATE, 6, 6, 2);
EXEC gs_insert_prediction(1.10, 'Risco Moderado', SYSDATE, 7, 7, 3);
EXEC gs_insert_prediction(1.40, 'Risco Alto', SYSDATE, 8, 8, 4);
EXEC gs_insert_prediction(1.30, 'Risco Alto', SYSDATE, 9, 9, 5);
EXEC gs_insert_prediction(0.80, 'Risco Baixo', SYSDATE, 10, 10, 1);

SELECT * FROM GS_PREDICTIONS;
