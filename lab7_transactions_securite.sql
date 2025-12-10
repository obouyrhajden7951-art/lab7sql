/* ============================================================
   LAB 7 – Transactions, Isolation, Locks et Sécurité MySQL
   ============================================================ */

/* ------------------------------------------------------------
   Étape 1 – Création de la base
   ------------------------------------------------------------ */
DROP DATABASE IF EXISTS banque_demo;
CREATE DATABASE banque_demo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE banque_demo;

/* ------------------------------------------------------------
   Étape 2 – Table compte
   ------------------------------------------------------------ */
CREATE TABLE compte (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  titulaire   VARCHAR(100) NOT NULL,
  solde       DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB;

-- Vérification
SHOW CREATE TABLE compte;

/* ------------------------------------------------------------
   Étape 3 – Données d’exemple
   ------------------------------------------------------------ */
INSERT INTO compte (titulaire, solde) VALUES
  ('Alice', 1000.00),
  ('Bob',   500.00);

SELECT * FROM compte;

/* ------------------------------------------------------------
   Étape 4 – Transaction COMMIT réussie
   ------------------------------------------------------------ */
START TRANSACTION;

UPDATE compte SET solde = solde - 200.00 WHERE titulaire = 'Alice';
UPDATE compte SET solde = solde + 200.00 WHERE titulaire = 'Bob';

COMMIT;

SELECT * FROM compte;

/* ------------------------------------------------------------
   Étape 5 – Transaction annulée (ROLLBACK)
   ------------------------------------------------------------ */
START TRANSACTION;

UPDATE compte SET solde = solde - 2000.00 WHERE titulaire = 'Alice';
UPDATE compte SET solde = solde + 2000.00 WHERE titulaire = 'Bob';

-- Annulation
ROLLBACK;

SELECT * FROM compte;

/* ------------------------------------------------------------
   Étape 6 – Niveaux d’isolation (à tester dans deux sessions)
   ------------------------------------------------------------ */
-- Session 1 :
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT solde FROM compte WHERE titulaire = 'Alice';

-- Session 2 :
-- UPDATE compte SET solde = solde + 100 WHERE titulaire = 'Alice';
-- COMMIT;

-- Retour session 1 :
-- SELECT solde FROM compte WHERE titulaire = 'Alice';

-- Tester aussi :
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

/* ------------------------------------------------------------
   Étape 7 – Verrous explicites (à tester dans deux sessions)
   ------------------------------------------------------------ */
-- Session 1 :
START TRANSACTION;
SELECT * FROM compte
WHERE titulaire = 'Alice'
FOR UPDATE;

-- Session 2 :
-- UPDATE compte SET solde = solde + 10 WHERE titulaire = 'Alice';
-- (bloqué)

-- Session 1 :
-- COMMIT;

/* ------------------------------------------------------------
   Étape 8 – Création utilisateur + privilèges
   ------------------------------------------------------------ */
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'P@ssw0rd!';

GRANT SELECT, INSERT, UPDATE
ON banque_demo.compte
TO 'app_user'@'localhost';

FLUSH PRIVILEGES;

-- Tester sous app_user :
-- mysql -u app_user -p banque_demo
-- Essayer un DELETE :
-- DELETE FROM compte WHERE id=1;  -- Doit être refusé

-- Révocation :
REVOKE UPDATE ON banque_demo.compte
FROM 'app_user'@'localhost';

FLUSH PRIVILEGES;
