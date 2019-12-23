USE employees;

-- 09장. 사용자 변수 적용 예제
-- 사용자 변수를 이용한 실제 사용예제


-- (603p - 코드블록2) : 9.3.1 N번째 레코드만 가져오기
--
-- **SELECT ..FROM .. WHERE .. GROUP BY .. HAVING .. ORDER BY ..** 실행순서
-- 1. **FROM** 절 : 대상 테이블을 참조한다.
-- 2. **WHERE** 절 : 대상이 아닌 데이터를 제거한다.
-- 3. **GROUP BY** 절 : 행들을 소그룹으로 묶는다.
-- 4. **HAVING** 절 : 그룹으로 묶인 값중 조건에 맞는것만 뽑는다.
-- 5. **SELECT** 절 : 데이터 값을 출력한다.
-- 6. **ORDER BY** 절 : 출력된 데이터를 정렬한다.
SELECT *
	FROM departments, (SELECT @rn := 0) x
	WHERE (@rn := @rn + 1) = 3
	ORDER BY dept_name;
	
SELECT *
	FROM departments, (SELECT @rn := 0) x
	HAVING (@rn := @rn + 1) = 3
	ORDER BY dept_name;
	
SELECT *
	FROM departments
	ORDER BY dept_name
	LIMIT 5;
	
-- 동일한 결과가 나타나지만, 수행과정이 다르다. 이해가 안되는 부분...


-- (604p - 코드블록2) : 9.3.2 누적 합계 구하기
-- **salary** 컬럼의 값을 누적시킨 값을 출력한다.
--	**SUM()** 함수의 경우는 조회된 모든 결과의 값의 합을 보여주지만, 아래의 쿼리는 각 결과별 누적값을 표현할 수 있다.
-- **FROM** 절에서 사용자 변수를 초기화 하고, **SELECT** 문에서 사용자 변수에 값을 누적시키고 있다.
--
-- 중요 : MySQL에서는 아래의 **FROM** 절과 같이 
-- 	파생된 테이블을 만드는 **FROM** 절 내의 서브쿼리에는 반드시! 별칭(ALias)를 부여해야 한다.
SELECT emp_no, salary, (@acc_salary := @acc_salary + salary) AS acc_salary
	FROM salaries, (SELECT @acc_salary := 0) x
	LIMIT 10;
	

-- (605p - 코드블록1) : 9.3.3 그룹별 랭킹(순서) 구하기
-- **LEAST()** 함수는 인자들 중 최소값을 반환한다.
--		**LEAST(숫자, 문자열)** 과 같이 숫자와 문자열을 같이 사용할 경우, **숫자** 를 반환한다.
--		**GREATEST(숫자, 문자열)** 의 경우, **문자열** 을 반환한다.
SELECT emp_no, first_name, last_name,
		IF(@prev_firstname = first_name,
			@rank := @rank + 1,
			@rank := 1 + LEAST(0, @prev_firstname := first_name)) tempRank
	
	FROM employees, (SELECT @rank := 0) x1, (SELECT @prev_firstname := 'DUMMY') x2
	
	WHERE first_name IN ('Georgi', 'Bezalel')
	
	ORDER BY first_name, last_name;
	

-- 위의 쿼리를 IF문 전후로 값 출력해 보기
SELECT emp_no, first_name, last_name, @prev_firstname, @rank,
		IF(@prev_firstname = first_name,
			@rank := @rank+1,
			@rank := 1 + LEAST(0, @prev_firstname := first_name)) tempRank,
		@prev_firstname, @rank
		
	FROM employees, (SELECT @rank := 0) x1, (SELECT @prev_firstname := NULL) x2
	WHERE first_name IN ('Georgi', 'Bezalel')
	ORDER BY first_name, last_name;
-- 참고 : **IF** 문
-- IF(조건문, 참일때 출력값, 거짓일때 출력값)
--
-- 사용자 변수를 사용하는 표현식이 복잡할 경우,
-- 표현식의 각 부분은 잘라서 직접 SELECT해보면 이해할 수 있을 것이다.
-- 예)
--		첫번째 수행 : IF(NULL = 'Bezalel', @rank := 0+1, @rank := 1+LEAST(0, '@prev_firstname := 'Bezalel'))
--			결과 : @rank=1, @prev_firstname='Bezalel'
--		두번째 수행 : IF('Bezalel' = 'Bezalel', @rank := 1+1, @rank := 1+LEAST(0, '@prev_firstname := 'Bezalel'))
--			결과 : @rank=2, @prev_firstname='Bezalel'


-- (608p) : 9.3.4 랭킹 업데이트 하기
-- 테스트용 tb_ranking 테이블 생성
CREATE TABLE tb_ranking(
	member_id		INT	NOT NULL,
	member_score	INT	NOT NULL,
	rank_no			INT 	NOT NULL,
	INDEX ix_memberscore(member_score)
);

-- 랭크 업데이트
-- 아래 쿼리에서 **@rank := 0** 으로 초기화 부분을 **UPDATE** 문 안에 넣지 않았다.
-- 이유는 **UPDATE** 의 **JOIN UPDATE** 와 **ORDER BY** 를 동시에 사용할 수 없기 때문이다.
SELECT @rank := 0;
UPDATE tb_ranking r
	SET r.rank_no = (@rank := @rank+1)
	ORDER BY r.member_score DESC;
	
-- (609p) : 9.3.5 GROUP BY와 ORDER BY가 인덱스를 사용하지 못하는 쿼리
-- **GROUP BY**와 **ORDER BY**가 함께 사용될 경우, 의도치 않은 결과가 나온다.
-- 대표적으로 **GROUP BY**와 **ORDER BY**가 함께 사용된 쿼리에서
--		그룹핑과 정렬이 인덱스를 사용하지 못하고 "Using temporary; Using filesort" 실행 계획이 사용되는 쿼리이다.
-- (무슨뜻인지 잘 모르겠다;)
CREATE TABLE tb_uservars(rid	VARCHAR(10));

INSERT INTO tb_uservars
VALUES('z'), ('y'), ('b'), ('c'), ('a'),
	('z'), ('y'), ('a'), ('b'), ('m'), ('n');
	
-- 정상적인 결과가 나오는 쿼리(**ORDER BY** 만 사용)
SELECT rid, @rank := @rank+1 AS tempRank
	FROM tb_uservars, (SELECT @rank := 0) x
	ORDER BY rid;
	
-- 의도치 않은 결과가 나오는 쿼리(**GROUP BY** 와 **ORDER BY** 둘 다 사용)
SELECT rid, @rank := @rank+1 AS tempRank
	FROM tb_uservars, (SELECT @rank := 0) x
	GROUP BY rid
	ORDER BY rid;
	
-- 이러한 현상은 정렬이 수행하기 전에 임시 테이블에 저장된 순서대로 사용자 변수가 연산되었기 때문이다.
-- 방법은 **GROUP BY** 와 **ORDER BY**가 수행되는 **SELECT**쿼리를 임시 테이블(파생 테이블)로 만들어 주면 된다.
-- (아래 두 쿼리는 **@rank**의 초기화 부분의 위치만 다를 뿐 동일한 쿼리이다)
SELECT rid, @rank := @rank+1
	FROM (SELECT rid
				FROM tb_uservars
				GROUP BY rid
				ORDER BY rid) tempX, (SELECT @rank := 0) tempY;
				
SELECT rid, @rank := @rank+1
	FROM (SELECT rid
				FROM tb_uservars, (SELECT @rank := 0) x
				GROUP BY rid
				ORDER BY rid) y;
				
-- 위의 두 쿼리는 **GROUP BY**와 **ORDER BY**가 인덱스를 사용하지 못하는 상태를 그대로 수행하는 방법이고,
-- 아래 쿼리는 인덱스를 새로 만들어 주는 방법이다.
ALTER TABLE tb_uservars ADD INDEX idx_rid(rid);

SELECT rid, @rank := @rank+1 AS tempRank
	FROM tb_uservars, (SELECT @rank := 0) x
	GROUP BY rid
	ORDER BY rid;
	
-- 중요한 점은 **GROUP BY** 와 **ORDER BY** 를 동시에 실행할 때는
-- **GROUP BY** 와 **ORDER BY** 를 수행하는 쿼리를 임시 테이블로 만들어 사용하라는 것이다.
-- 또는 **GROUP BY** 와 **ORDER BY**의 대상을 **INDEX**로 만들어 주는 것이다.