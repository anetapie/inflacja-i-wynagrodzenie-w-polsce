/* Tworzenie zapytań */

-- 1. List the average gross salary in each province in 2022. 

SELECT wojewodztwo, okres, rok, wynagrodzenie_brutto
FROM wynagrodzenia_brutto
WHERE okres = 'rok' AND rok = 2022
ORDER BY wynagrodzenie_brutto DESC;


-- 2. List the average gross salary in each province in 2022 in comparison with 2005. What was the difference in PLN? 

SELECT 
	t1.wojewodztwo,  
	t1."wynagrodzenie_brutto_2005",
	t2."wynagrodzenie_brutto_2022",
	"wynagrodzenie_brutto_2022" - "wynagrodzenie_brutto_2005" AS "roznica"
FROM (SELECT wojewodztwo, wynagrodzenie_brutto AS "wynagrodzenie_brutto_2005"
	FROM wynagrodzenia_brutto
	WHERE rok = 2005 AND okres = 'rok') as t1
	, 
	(SELECT wojewodztwo, wynagrodzenie_brutto AS "wynagrodzenie_brutto_2022"
	FROM wynagrodzenia_brutto
	WHERE rok = 2022 AND okres = 'rok') as t2
WHERE t1.wojewodztwo = t2.wojewodztwo 
ORDER BY "roznica" DESC;


-- 3. List how the salary has changed in the province Lower Silesia in 2022.

SELECT wojewodztwo, okres, rok, wynagrodzenie_brutto
FROM wynagrodzenia_brutto
WHERE wojewodztwo = 'DOLNOŚLĄSKIE' AND rok = 2022
ORDER BY okres;


-- 4. List the average annual inflation in Poland in particular years.  

SELECT DISTINCT rok, round(avg(wartosc), 2) AS srednia
FROM wsk_inflacji
GROUP BY rok
ORDER BY rok;


-- 5. List the years in which deflation was recorded.

SELECT rok, srednia 
FROM 
	(SELECT DISTINCT rok, round(avg(wartosc), 2) AS srednia
	FROM wsk_inflacji
	GROUP BY rok
	ORDER BY rok) AS srednia
WHERE srednia < 100;


-- 6. Name the average annual salary in Poland in particular years.

SELECT DISTINCT rok, round(avg(wynagrodzenie_brutto), 2) AS srednie_wynagrodzenie
FROM wynagrodzenia_brutto
GROUP BY rok
ORDER BY rok;


-- 7. List the average salary to inflation in Poland in particular years. 

SELECT FT.rok, FT.srednie_wynagrodzenie, FT.srednia_inflacja
FROM ((
	SELECT DISTINCT rok, round(avg(wynagrodzenie_brutto), 2) AS srednie_wynagrodzenie
	FROM wynagrodzenia_brutto
	GROUP BY rok
	ORDER BY rok) AS wb
	  INNER JOIN (
	SELECT DISTINCT rok AS rok2, round(avg(wartosc), 2) AS srednia_inflacja
	FROM wsk_inflacji
	GROUP BY rok2
	ORDER BY rok2) AS si
   ON wb.rok = si.rok2) AS FT;