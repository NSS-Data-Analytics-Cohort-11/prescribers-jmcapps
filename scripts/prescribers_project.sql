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

SELECT prescriber.specialty_description, SUM(prescription.total_claim_count)
FROM prescriber
LEFT JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
HAVING SUM(prescription.total_claim_counT) IS NULL;

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

SELECT population.population, f.county
FROM population
LEFT JOIN cbsa
USING (fipscounty)
LEFT JOIN fips_county AS f
USING (fipscounty)
WHERE cbsa.cbsa IS NULL
ORDER BY population.population DESC;

--Answer: Sevier County

-- 6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT prescription.drug_name, prescription.total_claim_count
FROM prescription
WHERE prescription.total_claim_count >= '3000'
GROUP BY prescription.drug_name, prescription.total_claim_count;

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
FROM prescription
INNER JOIN drug
ON drug.drug_name = prescription.drug_name
WHERE prescription.total_claim_count >= '3000'
GROUP BY prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag;

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, 
	prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name
FROM prescription
INNER JOIN drug
ON drug.drug_name = prescription.drug_name
LEFT JOIN prescriber
ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count >= '3000'
GROUP BY prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name;

-- 7. a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y').

SELECT prescriber.npi, drug.drug_name
FROM prescriber 
CROSS JOIN drug 
WHERE prescriber.specialty_description ILIKE 'pain management'
AND prescriber.nppes_provider_city ILIKE 'Nashville'
AND drug.opioid_drug_flag = 'Y';

-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescriber.npi, drug.drug_name, 
	(SELECT 
		SUM(prescription.total_claim_count)
	FROM prescription
	WHERE prescriber.npi = prescription.npi
	AND prescription.drug_name = drug.drug_name) AS total_claim
FROM prescriber 
CROSS JOIN drug
INNER JOIN prescription
USING (npi)
WHERE prescriber.specialty_description ILIKE 'pain management'
AND prescriber.nppes_provider_city ILIKE 'Nashville'
AND drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
ORDER BY prescriber.npi DESC;

-- 7. c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.

SELECT prescriber.npi, drug.drug_name, 
	(SELECT(COALESCE(SUM(prescription.total_claim_count),0))
	FROM prescription
	WHERE prescription.npi = prescriber.npi
	AND prescription.drug_name = drug.drug_name) AS total_claim
FROM prescriber 
CROSS JOIN drug
INNER JOIN prescription
USING (npi)
WHERE prescriber.specialty_description ILIKE 'pain management'
AND prescriber.nppes_provider_city ILIKE 'Nashville'
AND drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
ORDER BY prescriber.npi DESC;






