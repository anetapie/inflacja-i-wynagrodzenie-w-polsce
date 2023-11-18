# SQL Projekt - Inflacja i wynagrodzenie w Polsce

Analiza statystyk wynagrodzeń brutto i inflacji w Polsce.


## Metodologia

Skompilowanie danych statystycznych Głównego Urzędu Statystycznego dostępnych na stronie www.stat.gov.pl i wysłanie zapytań do bazy danych w programie pgAdmin 4 (PostgresSQL) w celu przeprowadzenia poniższej analizy;

## Główny cel

1. Wymienienie średniego wynagrodzenia brutto w każdym województwie w 2022 roku. 
2. Zestawienie średniego wynagrodzenia brutto w każdym województwie w 2022 roku w porównaniu z 2005 rokiem oraz obliczenie różnicy.
3. Określenie zmiany wynagrodzenia w województwie dolnośląskim w 2022 roku.
4. Obliczenie średniorocznej inflacji w Polsce w poszczególnych latach.  
5. Wyróżnienie lat, w których odnotowano deflację.
6. Wymienieie średniorocznego wynagrodzenia w Polsce w poszczególnych latach.
7. Zestawienie relacji średniego wynagrodzenia do inflacji w Polsce w poszczególnych latach.

 
## Tworzenie bazydanych 

```
CREATE DATABASE inflacja_i_wynagrodzenie_w_polsce
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
```

## Tworzenie i kopiowanie tabel

#### Tabela 1. "wynagrodzenia brutto"
```
CREATE TABLE wynagrodzenia_brutto(
	wojewodztwo varchar(40),
	okres varchar(30),
	rok INTEGER,
	wynagrodzenie_brutto decimal(10,2),
	jednostka_miary varchar(10)
);

COPY wynagrodzenia_brutto
FROM '<ROOT_PATH>\data\wynagrodzenia_brutto.txt'
WITH (FORMAT CSV, HEADER,DELIMITER ';');

```
#### Tabela 2. "wskaźnik inflacji"
```
CREATE TABLE wsk_inflacji(
		sposob_prezentacji varchar(60),
		rok INTEGER,
		kwartal varchar(20),
		wartosc decimal(10,2)
	);

COPY wsk_inflacji
FROM '<ROOT_PATH>\data\wsk_inflacji.txt'
WITH (FORMAT CSV, HEADER,DELIMITER ';');
```

## Ujednolicenie nazw kolumn na potrzeby analizy
```
ALTER TABLE wsk_inflacji
RENAME COLUMN kwartal TO okres;
```


# Tworzenie zapytań

### 1. Wymienienie średniego wynagrodzenia brutto w każdym województwie w 2022 roku. 

```
SELECT wojewodztwo, okres, rok, wynagrodzenie_brutto
FROM wynagrodzenia_brutto
WHERE okres = 'rok' AND rok = 2022
ORDER BY wynagrodzenie_brutto DESC;
```
#### wynik:
|    |wojewodztwo    |rok   |wynagrodzenie_brutto|
|----|---------------|------|--------------------|
|1   |MAZOWIECKIE    |2022  |7908.51             |
|2   |DOLNOŚLĄSKIE   |2022  |6964.36             |
|3   |MAŁOPOLSKIE    |2022  |6906.02             |
|4   |POMORSKIE      |2022  |6847.09             |
|5   |ŚLĄSKIE        |2022  |6769.88             |
--snip--


### 2. Zestawienie średniego wynagrodzenia brutto w każdym województwie w 2022 roku w porównaniu z 2005 rokiem oraz obliczenie różnicy. 

```
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
```
#### wynik:
|  |wojewodztwo    |wynagrodzenie_brutto_2005  |wynagrodzenie_brutto_2022  |roznica  |
|--|---------------|---------------------------|---------------------------|---------|
|1 |MAZOWIECKIE    |3240.37	                   |7908.51                    |4668.14  |
|2 |MAŁOPOLSKIE    |2344.00	                   |6906.02                    |4562.02  |
|3 |DOLNOŚLĄSKIE   |2493.52	                   |6964.36                    |4470.84  |
|4 |POMORSKIE      |2553.97	                   |6847.09                    |4293.12  |
|5 |ŚLĄSKIE        |2623.85	                   |6769.88                    |4146.03  |

--snip--


### 3. Określenie zmiany wynagrodzenia w województwie dolnośląskim w 2022 roku.

```
SELECT wojewodztwo, okres, rok, wynagrodzenie_brutto
FROM wynagrodzenia_brutto
WHERE wojewodztwo = 'DOLNOŚLĄSKIE' AND rok = 2022
ORDER BY okres;
```
#### wynik:
|  |wojewodztwo    |okres            |rok    |wynagrodzenie_brutto  |
|--|---------------|-----------------|-------|----------------------|
|1 |DOLNOŚLĄSKIE   |I kwartał	     |2022   |6731.86               |
|2 |DOLNOŚLĄSKIE   |II kwartał	     |2022   |6844.32               |
|3 |DOLNOŚLĄSKIE   |III kwartał      |2022   |6889.33               |
|4 |DOLNOŚLĄSKIE   |IV kwartał	     |2022   |7386.84               |
|5 |DOLNOŚLĄSKIE   |rok	             |2022   |6964.36               |


### 4. Obliczenie średniorocznej inflacji w Polsce w poszczególnych latach.  

```
SELECT DISTINCT rok, round(avg(wartosc), 2) AS srednia
FROM wsk_inflacji
GROUP BY rok
ORDER BY rok;
```
#### wynik:
|  |rok    |srednia    |
|--|-------|-----------|
|1 |2005   |102.15     |
|2 |2006   |101.03     |
|3 |2007   |102.48     |
|4 |2008   |104.23     |
|5 |2009   |103.45     |

--snip--


### 5. Wyróżnienie lat, w których odnotowano deflację.  

```
SELECT rok, srednia 
FROM 
	(SELECT DISTINCT rok, round(avg(wartosc), 2) AS srednia
	FROM wsk_inflacji
	GROUP BY rok
	ORDER BY rok) AS srednia
WHERE srednia < 100;
```
#### wynik:
|  |rok    |srednia    |
|--|-------|-----------|
|1 |2005   |99.98      |
|2 |2006   |99.08      |
|3 |2007   |99.40      |


### 6. Wymienieie średniorocznego wynagrodzenia w Polsce w poszczególnych latach.

```
SELECT DISTINCT rok, round(avg(wynagrodzenie_brutto), 2) AS srednie_wynagrodzenie
FROM wynagrodzenia_brutto
GROUP BY rok
ORDER BY rok;
```
#### wynik:
|  |rok    |srednie_wynagrodzenie    |
|--|-------|-------------------------|
|1 |2005   |2351.13                  |
|2 |2006   |2491.71                  |
|3 |2007   |2722.71                  |
|4 |2008   |3006.56                  |
|5 |2009   |3154.90                  |

--snip--


### 7. Zestawienie relacji średniego wynagrodzenia do inflacji w Polsce w poszczególnych latach. 

```
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
```
#### wynik:
|  |rok    |srednie_wynagrodzenie    |srednia_inflacja   |
|--|-------|-------------------------|-------------------|
|1 |2005   |2351.13                  |102.15             |
|2 |2006   |2491.71                  |101.03             |
|3 |2007   |2722.71                  |102.48             |
|4 |2008   |3006.56                  |104.23             |
|5 |2009   |3154.90                  |103.45             |

--snip--
