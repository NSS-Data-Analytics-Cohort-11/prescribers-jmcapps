-- 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescriber.npi
ORDER BY total_claims DESC;

--Answer: npi 1881634483 total claims 99707

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims,
prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
FROM prescriber
INNER JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescriber.npi, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
ORDER BY total_claims DESC;

--Answer: Bruce Pendley...Family Practice

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims,
prescriber.specialty_description
FROM prescriber
INNER JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescriber.npi, prescriber.specialty_description
ORDER BY total_claims DESC;

--Answer: Family Practice

-- b. Which specialty had the most total number of claims for opioids?

SELECT SUM(prescription.total_claim_count) AS total_claims,
prescriber.specialty_description, drug.opioid_drug_flag
FROM prescriber
INNER JOIN prescription
ON prescription.npi = prescriber.npi
INNER JOIN drug
ON drug.drug_name = prescription.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description, drug.opioid_drug_flag
ORDER BY total_claims DESC;

--Answer: Nurse Practitioner

-- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- 3. a. Which drug (generic_name) had the highest total drug cost?

SELECT drug.generic_name, SUM(prescription.total_drug_cost)
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC;

--Answer: INSULIN GLARGINE

-- b. Which drug (generic_name) has the hightest total cost per day?

SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply), 2)
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply) DESC;

--Answer: C1 ESTERASE INHIBITOR

-- 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'anibiotic'
		ELSE 'neither'
	END AS drug_type
FROM drug;

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics.

SELECT 
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'anibiotic'
		ELSE 'neither'
	END AS drug_type, SUM(MONEY(total_drug_cost))
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_type
ORDER BY SUM(total_drug_cost);

--Answer: opioid

-- 5. a. How many CBSAs are in Tennessee?

SELECT COUNT(cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

--Answer: 56

-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsa.cbsaname, SUM(population.population)
FROM cbsa
INNER JOIN population
ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsa.cBsaname
ORDER BY SUM(population.population);

--Answer: largest combines population = Nashville-Davidson--Murfreesboro--Franklin, TN
-- smallest combined poplation = Morristown, TN

-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.





