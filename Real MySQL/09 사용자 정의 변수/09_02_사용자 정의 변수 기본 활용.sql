USE employees;

-- 09장. 사용자 변수 기본 활용


-- 사용자 변수는 하나의 컨넥션에서는 공유된다.
-- 이는 컨넥션 풀을 사용할 경우, 서로 공유가 된다는 뜻이 된다.
-- 그러므로 사용자 변수를 쓰기 전에는 항상 **SET** 문으로 초기화를 하자.

-- (601p - 코드블록1)
-- 사용자 변수를 매번 **SET** 문으로 초기화 하기는 번거롭기 때문에 다음과 같이 **FROM** 문에서 초기화 하자.
-- 이유는 **FROM** 문은 쿼리가 실행되는 동안 딱 1번만 참조되기 때문에 초기화에 적합하다.
-- 또한 **FROM** 문의 **SELECT @rownum := 0;** 문장은 하나의 값만 가지는 스칼라 테이블이므로, 
-- 	조인 조건없이 사용해도 성능에 영향이 없다.
-- (**FROM** 문에 사용한 **SELECT** 문은 Alias(예명)을 붙여야 한다.)
--
-- 이 방법을 사용할 수 없는 경우.
-- **ORDER BY** 가 사용된 **JOIN UPDATE** 또는 **JOIN DELETE** 문장에서는 사용할 수 없다.
-- 이유는 **JOIN UPDATE** 나 **JOIN DELETE** 문에서는 **FROM** 절에 사용된 테이블이 2개 이상일 때, 
-- **ORDER BY** 절을 사용할 수 없기 때문이다.
--
-- 메뉴얼상 **L-value 표현식** 이라는 표현은 **(@rownum := @rownum + 1)** 과 같이 좌측값이 반환됨을 말한다.
SELECT (@rownum := @rownum + 1) AS rownum, emp_no, first_name
FROM employees, (SELECT @rownum := 0) der_tap
LIMIT 5;



-- (601p - 코드블록2)
-- 아래의 쿼리문은 **@old_salary** 에 값을 대입하는 작업을 의도한 것인데, 필요하지 않은 결과도 함꼐 출력되고 있다.
SET @old_salary := 900000;
SELECT @old_salary, salary, @old_salary := salary
FROM salaries
LIMIT 1;

-- 불필요한 3번째 컬럼을 지워보자.
-- **LEAST** 문은 가장 작은 값을 반환하는 함수이므로, 첫번째 인자인 -1값이 항상 반환된다.
-- **GREATEST** 문은 가장 큰 값을 반환하는 함수이므로, 양수인 첫번째 인자(**@old_salary**)가 반환된다.
-- 이러한 방법으로 **GREATEST** 문과 **LEAST** 문을 조합하여, 불필요한 컬럼을 지울 수 있다.
-- (**@old_salary** 의 값을 **salary** 값으로 초기화 하는 동시에 **salary**값만 반환하게 하는 트릭)
SET @old_salary := 900000;
SELECT @old_salary, GREATEST(salary, LEAST(-1, @old_salary := salary)) AS salary
FROM salaries
LIMIT 1;

SELECT @old_salary;

-- 위의 예제는 사용자 변수를 초기화 하기 위해 **SELECT** 문 이전에 **SET** 명령을 실행해야 한다.
-- 아래와 같이 **FROM** 절에서 수행하면 하나의 **SELECT** 문으로 만들 수 있다.
-- (**FROM** 절의 **(SELECT @old_salary := 900000) x**에서 **@old_salary**를 초기화 하고 있다.)
-- 중요함
SELECT @old_salary, GREATEST(salary, LEAST(-1, @old_salary := salary)) AS salary
FROM salaries, (SELECT @old_salary := 900000) x
LIMIT 1;