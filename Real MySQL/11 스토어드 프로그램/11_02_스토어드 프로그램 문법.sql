USE employees;

-- 11장. 스토어드 프로그램
-- 11.2 스토어드 프로그램 문법

-- 스토어드 프로그램은 헤더와 바디로 나뉜다.


-- 주의사항
-- 스토어드 프로그램을 실행할 때는, 
-- 	**스토어드 프로그램 명** 과 **(괄호)**, **파라미터** 사이의 공백이 있으면 않된다.


--	헤더
--		1. 스토어드 프로그램의 헤더부를 정의부 라고도 한다.
--		2. 역할
--			* 스토어드 프로그램 이름
--			* 입출력값 명시
--			* 보안 설정
--			* 스토어드 프로그램의 작동방식 옵션 설정


-- 바디
--		1. 스토어드 프로그램 본문 이라고도 한다.
--		2. 역할
--			* 스토어드 프로그램이 호출되었을 때, 실행하는 내용 작성


-- (651p) : 11.2.2 스토어드 프로시저
--
-- 스토어드 프로시저를 사용하는 경우
--		* 여러 쿼리들이 서로 데이터를 주고받아야 하는 경우,
--			하나의 그룹으로 묶어서 독립적으로 실행하기 위해 사용한다.
--		* 반복적으로 실행되어야 하는 경우에 사용한다.
--		* 예)
--			첫번째 쿼리결과를 이용하여, 두번째 쿼리를 실행해야 하는 경우
--
--	스토어드 프로시저는 반드시 독립적으로 호출해야 한다.
--		(**SELECT** 문이나 **UPDATE** 문에서는 스토어드 프로시저를 참조할 수 없다)


-- (652p - 코드블록1) : 스토어드 프로시저 생성 및 삭제

-- 스토어드 프로시저 생성
DELIMITER ;;

CREATE PROCEDURE sp_sum(IN param1 INTEGER, IN param2 INTEGER, OUT param3 INTEGER)
	BEGIN
		SET param3 = param1 + param2;
	END
;;

DELIMITER ;
-- **DELIMITER**
--		: 스토어드 프로시저의 끝을 (;)로 할 경우,
--			스토어드 프로시저 내부 코드의 끝과 겹치기 때문에 스토어드 프로시저로써 묶여지지 않는다.
--			때문에 **종료문자**인 (;)를 다른 기호로 바꾸고, 스토어드 프로시저가 종료된 후에 다시 (;)로 바꾼다.
-- **CREATE PROCEDURE sp_sum** 
--		: 스토어드 프로시저 이름은 **sp_sum** 이다.
-- **(IN param1 INTEGER, IN param2 INTEGER, OUT param3 INTEGER)
--		: 파라미터를 설정한다.
--		* IN : 입력 전용 파라미터
--		* OUT : 출력 전용 파라미터
--		* INOUT : 입력 출력 공용 파라미터
--	**BEGIN ~ END**
--		: 스토어드 프로시저가 수행하는 본문의 시작과 끝이 된다.
--	**SET**
--		: **OUT** 또는 **INOUT** 파라미터에 값을 대입할 때는 **SET** 문을 사용해야 한다.
--		* 스토어드 프로시저에서는 **RETURN** 을 사용할 수 없다.(기본 반환값 설정이 불가능 하다는 뜻)


-- **ALTER PROCEDURE**
--		: 스토어드 프로시저의 보안 또는 작동방식과 같은 특성을 변경할 때 사용
--		(스토어드 프로시저의 마라미터나 본문은 변경 불가 - **DROP PROCEDURE** 후 다시 생성할 수밖에 없다.)
ALTER PROCEDURE sp_sum SQL SECURITY DEFINER;


-- **DROP PROCEDURE**
DROP PROCEDURE sp_sum;

DELIMITER ;;

CREATE PROCEDURE sp_sum(IN param1 INTEGER, IN param2 INTEGER, OUT param3 INTEGER)
	BEGIN
		SET param3 = param1 + param2;
	END
;;

DELIMITER ;


-- 스토어드 프로시저 실행
--	* 스토어드 프로시저와 스토어드 함수의 차이점 중 하나는 **실행방법**이다.
-- * 스토어드 프로시저는 **SELECT** 또는 **UPDATE** 문에서 사용할 수 없다.
-- * 스토어드 프로시저는 **CALL** 명령어로 실행해야 한다.
-- * 파라미터
-- 	* **IN** 타입 파라미터에는 상수값 또는 변수를 입력할 수 있다.
--		* **OUT** 또는 **INOUT** 타입 파라미터에는 **세션변수** 를 사용해야 한다.
-- **IN** 타입에 리터럴 상수를 사용하여 스토어드 프로시저를 호출한 예
SET @result := 0;
SELECT @result;

CALL sp_sum(1, 2, @result);
SELECT @result;

-- **IN** 타입에 **세션변수** 를 사용하여 스토어드 프로시저를 호출한 예
SET @param1 := 1;
SET @param2 := 2;
SET @result := 0;

CALL sp_sum(@param1, @param2, @result);
SELECT @result;


-- 스토어드 프로시저 커서 반환
-- (내용이 커서가 아니라 디버깅 방법인것 같음)
--
-- 프로시저 디버깅 하기
--		동작 : 스토어드 프로시저가 동작하기 전, 파라미터값을 화면에 표시하기
DROP PROCEDURE sp_sum;

DELIMITER $$

CREATE PROCEDURE sp_sum(IN param1 INTEGER, IN param2 INTEGER, OUT param3 INTEGER)
	BEGIN
		SELECT '> Stored Procedure started.' AS debug_message;
		SELECT CONCAT('   > param1 : ', param1) AS debug_message;
		SELECT CONCAT('   > param2 : ', param2) AS debug_message;
		
		SET param3 = param1 + param2;
		
		SELECT '> Stored Procedure completed.' AS debug_message;
	END$$
	
DELIMITER ;

CALL sp_sum(1, 2, @result);
-- 위 쿼리를 실행하면, 화면에 커서단위로 결과를 나타낸다.


-- 스토어드 함수
-- * 스토어드 함수는 하나의 SQL 문으로 작성이 불가능한 기능을 하나의 SQL문으로 구현해야 할때 사용한다.
--		* 예) 각 부서별로 가장 최근에 배속된 사원을 2명씩 가져오기
-- * 스토어드 함수는 SQL문의 일부로 사용한다. (**CALL** 명령으로 사용하지 못한다)

-- 스토어드 함수 생성
-- * **CREATE FUNCTION** 명령으로 스토어드 함수를 생성한다.
-- * 스토어드 함수의 파라미터는 모두 **읽기전용** 이다.
--		(**IN**, **OUT**, **INOUT** 같은 형식을 사용할 수 없다.)
-- * 스토어드 함수의 정의부에 반드시 반환되는 타입을 **RETURNS** 명령으로 명시해야 한다.
DELIMITER $$

CREATE FUNCTION sf_sum(param1 INTEGER, param2 INTEGER) 
		RETURNS INTEGER
		
	BEGIN
		DECLARE param3 INTEGER DEFAULT 0;
		SET param3 = param1 + param2;
		
		RETURN param3;
	END$$

DELIMITER ;

-- 아래 쿼리로 설정을 변경하기 전에는 **CREATE FUNCTION** 실행시 1418 에러가 발생하였다.
-- 해결방법은 아래 쿼리를 실행하면 된다.(설정 변경)
SET GLOBAL log_bin_trust_function_creators = 1;

-- * 스토어드 함수의 본문(**BEGIN ~ END**)에서는 **SELECT ~ INTO** 문은 사용할 수 있다.
-- 	(결과 셋을 반환하는 **SELECT** 문은 사용할 수 없다.)

-- * 스토어드 함수도 스토어드 프로시저와 같이 **ALTER FUNCTION** 명령을 사용할 수 있다.
-- 	* 스토어드 함수의 본문이나, 입력 파라미터는 변경할 수 없다.
ALTER FUNCTION sf_sum SQL SECURITY DEFINER;

-- * 스토어드 함수의 입력 파라미터나 본문을 변경하려면, **DROP FUNCTION** 으로 제거 후,
--		다시 생성하는 방법밖에 없다.
DROP FUNCTION sf_sum;

DELIMITER $$

CREATE FUNCTION sf_sum(param1 INTEGER, param2 INTEGER)
		RETURNS INTEGER
	
	BEGIN 
		DECLARE param3 INTEGER DEFAULT 0;
		SET param3 = param1 + param2;
		
		RETURN param3;
	END$$

DELIMITER ;


-- 스토어드 함수 실행
-- * 스토어드 함수는 스토어드 프로시저와 다르게 **CALL** 명령으로 실행할 수 없다.
-- * 스토어드 함수는 **SELECT** 문을 이용하여 실행한다.
--		(**CALL** 명령은 MySQL이 스토어드 프로시저를 실행한다고 해석한다.)
SELECT sf_sum(1, 2) AS sum;