# Child Malnutrition & Anemia in India: Socio-Economic Determinants Across Three States

---

## Authors

Abhishek Anand Sinha, Anoushka Purohit, Chaitanya Dandale & Durga Sreedevi PR

---

## Research Question

> *Using logistic regression, analyze the socio-economic determinants of anemia and malnutrition (stunting, wasting, underweight) among children under 5 years in Uttar Pradesh, Bihar, and West Bengal.*

---

## Dataset

- **Source:** National Family Health Survey-5 (NFHS-5), 2019–21, Ministry of Health & Family Welfare, Government of India (KR, Children's Recode, and PR, Household Members' Recode files)
- **Unit of Analysis:** Children aged 0–59 months (6–59 months for the anemia model)
- **States Covered:** Uttar Pradesh, Bihar, West Bengal
- **Sample:** NFHS-5 surveyed 6,36,699 households, 7,24,115 women, and 1,01,839 men nationally; state-wise child-level samples were drawn from the merged KR–PR files for UP, Bihar, and West Bengal

> ⚠️ The raw data file is **not included** in this repository as it is government microdata subject to DHS Program data-use terms. See [`data/README_data.md`](data/README_data.md) for instructions on how to access and prepare it.

---

## Methodology

1. **Data merging:** KR file (children) merged with PR file (household members) on cluster, household, and child line number (`hv001 hv002 hvidx`); kept successful matches only
2. **Sample restriction:** living children (`b5==1`), de facto household members (`hv103==1`), under 60 months (`hc1<60`)
3. **Survey-weighted logistic regression** (`svy: logit`, with `svyset` on PSU/strata/weight) run independently by state, for each of four outcomes
4. Odds ratios, 95% CIs, and significance levels exported to Excel via `outreg2`

### Outcome Variables

| Outcome | Definition | Source variable |
|---|---|---|
| `stunted` | Height-for-age Z-score < -2 SD | `hc70` |
| `wasted` | Weight-for-height Z-score < -2 SD | `hc72` |
| `underweight` | Weight-for-age Z-score < -2 SD | `hc71` |
| `child_anemic` | Any anemia (mild/moderate/severe), children 6–59 months | `hc57` |

### Independent Variables

| Variable | Description |
|---|---|
| `residence` | Urban / Rural |
| `religion_new` | Hindu (ref) / Muslim / Christian / Others |
| `caste_new` | SC / ST / OBC / Others / Missing |
| `v190` | Wealth quintile (Poorest → Richest) |
| `age_mother_new` | Mother's age group: <25 / 25–34 / 35+ |
| `mother_edu` | Mother's education: None / Primary / Secondary / Higher |
| `mother_anemic` | Mother's anemic status |
| `diarrhea` | Child had diarrhea in last 2 weeks |
| `low_bw` | Low birth weight (<2.5 kg) |
| `birth_order_cat` | 1st / 2nd–3rd / 4th+ child |
| `total_children_cat` | Total children ever born to mother, grouped |

---

## Key Findings

### Anemia — Maternal anemia is the strongest predictor across all three states

| State | Odds Ratio | Interpretation |
|---|---|---|
| West Bengal | 1.738*** | 73.8% higher odds if mother is anemic |
| Bihar | 1.591*** | 59.1% higher odds |
| Uttar Pradesh | 1.470*** | 47.0% higher odds |

### Maternal education is consistently protective

- UP: mothers with higher/graduate education show **22.4% lower odds** (OR 0.776***) of anemic children vs. no education
- West Bengal: higher maternal education reduces odds of underweight (OR 0.568***) and stunting (OR 0.620**)

### Maternal age (35+) is protective against both anemia and stunting

- Anemia reduced by up to **41.6%** in Bihar (OR 0.584***) and **33.2%** in UP (OR 0.668***)
- Stunting reduced by up to **27.6%** in West Bengal (OR 0.724***)

### Recent diarrhea raises odds of anemia and wasting

- Anemia odds rise by 37.9% (WB), 29.6% (Bihar), 27.6% (UP)
- Wasting odds rise 13.3% in UP (OR 1.133*)

### Wealth, residence, religion, and caste effects vary by state and outcome

- In UP, wealth quintile and urban/rural residence are largely statistically insignificant for anemia
- In Bihar and West Bengal, stunting/wasting/underweight show a clearer wealth and caste (SC/ST/OBC) gradient

*(*, **, *** denote significance at 10%, 5%, and 1% respectively, see `outputs/` for full regression tables)*

---

## Policy Context

The analysis is framed against existing government interventions, **Anemia Mukt Bharat**, **POSHAN 2.0**, the **Mothers' Absolute Affection (MAA)** programme, **National Deworming Day**, and **Village Health Sanitation and Nutrition Days**, and argues for treating malnutrition and anemia as a combined, multi-sectoral problem rather than through siloed schemes.

---

## How to Reproduce the Analysis

1. Obtain the NFHS-5 KR and PR recode files from the DHS Program (see `data/README_data.md`)
2. Place the data files in the `data/` folder as specified in the do file
3. Open Stata and run `code/nfhs_malnutrition_anemia.do` from start to finish
4. Regression outputs (odds ratios, CIs) are exported to `outputs/` as `.xls` files, one per outcome

**Software:** Stata
**Packages required:** `outreg2`, standard survey commands (`svyset`, `svy: logit`)

---

## Data Ethics Note

NFHS-5 microdata is anonymised, unit-level, and made available by the DHS Program under a data-use agreement, no individual respondent can be identified. All analysis uses survey weights (`hv005`) and the survey design (PSU/strata) to produce state-representative estimates.

---

## License

This project is licensed under [CC BY 4.0](LICENSE), you are free to use, share, and adapt with attribution.
