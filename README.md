# SunscreenAllergenCode
Code reproducing the sunscreen allergen NAC-80 text-matching algorithm used in the associated manuscript

## Purpose
This repository contains the code used to reproduce the text-matching algorithm described in the manuscript “Allergen content of inactive ingredients in best-selling sunscreens.” The algorithm identifies North American Contact Dermatitis Group (NAC-80) allergens within sunscreen inactive ingredient lists using rule-based string processing and matching.

## Algorithm overview
Inactive ingredient strings are standardized by converting text to lowercase, removing parentheses/parenthetical text and trimming leading and trailing whitespace. Ingredient lists are then split into individual components separated by commas. Exact string matching is performed against a predefined list of allergen strings derived from the NAC-80 panel (see nac80_list.txt). In addition, predefined partial-matching rules are applied for select ingredients with variable naming conventions, including acrylates, tocopherol acetate, fragrance-related terms, and mix-related terms (including paraben/parabens). The output of the text-matching script was compared with results from manual review, as described in the manuscript.

## Reproducibility
All analyses were performed in R (version 4.2.2).

To run the text-matching algorithm:
```r
source("NAC80_Comparison.R")
```

## File map
- README.md --> repository overview
- NAC80_Comparison.R --> main script implementing the sunscreen allergen text-matching algorithm
- example_input.csv --> example inactive ingredient list for testing the algorithm
- example_output.csv --> example algorithm output
- nac80_list.txt --> NAC-80 reference list used in algorithm
