USE employees;

-- 09장. 사용자 정의 변수 소개


-- (598p - 코드블록1) 사용자 정의 변수 만들기
-- 사용자 정의 변수는 **@변수명** 의 형식으로 만든다.
-- SET 문장으로 값을 할당함과 동시에 생성된다.
-- SET 문장으로 값을 대입할 떄는 **:=** 또는 **=** 연산자를 사용한다.
-- SQL 문장에서 **표현식** 을 사용할 수 있는 곳에서는 언제나 사용자 변수를 사용할 수 있다.
SET @var := 'My first user variable';
SET @var1 := 'My first', @var2 := 'user variable';
SELECT @var AS var1, CONCAT(@var1, '★', @var2) AS var2;


-- (598p - 코드블록2) 사용자 정의 변수를 참조하고 변경된 값을 다시 그 사용자 변수에 대입하는 형식(결과 레코드에 넘버링을 하게된다)
-- 경고가 발생하는데, 이는 참조한 사용자 변수에 변경된 값을 다시 그 사용자 변수에 대입하는 것은 권장하지 않는다는 뜻이다.
-- MySQL 버전별로 동작방식이 다를 수 있기 때문에 발생하는 경고이므로, 동일한 버전에는 무시해도 괜찮다.
-- (위의 내용을 알고는 있자)
SET @rownum := 0;
SELECT (@rownum := @rownum + 1) AS rownum, emp_no, first_name FROM employees LIMIT 5 OFFSET 5;


-- (599p - 코드블록1) 
-- (@rank := @rank + 1) : @rank에 @rank+1 갑을 대입한 후, @rank값 조회하기
-- 책에서는 속성명을 rank로 사용했지만, 사용이 않된다. 그래서 empRank로 사용
-- GREATEST(값1, 값2) : 인자 중, 가장 큰값을 반환한다.
-- WHERE 문에서 0은 false, 그 외는 true가 되기 때문에, 아래의 GREATEST 문은 항상 참이다.
SET @rank := 0;
SELECT (@rank := @rank + 1) empRank, emp_no
	FROM employees
	WHERE hire_date > '1999-12-01'
	AND GREATEST(1, (SELECT @rank := 0));

-- 위의 쿼리에서 GREATEST 문을 변형한 형태이다.
-- GREATEST 문의 결과값은 동일하지만, 아래의 쿼리에서는 empRank값이 증가되지 않는 현상이 발생한다.
-- 이러한 현상은 사용자 정의 변수를 사용할 떄 발생하기 때문에, 사용자 변수를 사용할 때는 여러번 채크를 해야 한다.
-- (나중에 원인을 찾을 수 없기 때문)
SET @rank := 0;
SELECT (@rank := @rank + 1) empRank, emp_no
	FROM employees
	WHERE hire_date > '1999-12-01' AND GREATEST(1, (SELECT @rank := @rank * 0));




