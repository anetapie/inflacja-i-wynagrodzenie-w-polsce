-- /* Tworzenie i kopiowanie tabel */

DROP TABLE IF EXISTS wynagrodzenia_brutto; 
DROP TABLE IF EXISTS wsk_inflacji;

-- Tabela 1. "wynagrodzenia brutto"

CREATE TABLE wynagrodzenia_brutto(
	wojewodztwo varchar(40),
	okres varchar(30),
	rok INTEGER,
	wynagrodzenie_brutto decimal(10,2),
	jednostka_miary varchar(10)
);

COPY wynagrodzenia_brutto
FROM 'D:\projekt_inflacja_i_wynagrodzenie_w_polsce\dane\wynagrodzenia_brutto.txt'
WITH (FORMAT CSV, HEADER,DELIMITER ';');


-- Tabela 2. "wskaźnik inflacji"

CREATE TABLE wsk_inflacji(
		sposob_prezentacji varchar(60),
		rok INTEGER,
		kwartal varchar(20),
		wartosc decimal(10,2)
	);

COPY wsk_inflacji
FROM 'D:\projekt_inflacja_i_wynagrodzenie_w_polsce\dane\wsk_inflacji.txt'
WITH (FORMAT CSV, HEADER,DELIMITER ';');


-- Ujednolicenie nazw kolumn na potrzeby analizy

ALTER TABLE wsk_inflacji
RENAME COLUMN kwartal TO okres;