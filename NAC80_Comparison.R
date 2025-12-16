# SCRIPT TO CROSSLIST A SUNSCREEN'S INACTIVE INGREDIENTS AGAINST THE NAC-80 LIST

# Steps:
#   1) Define the NAC-80 allergen list
#   2) Take a sunscreen's ingredient list as input
#   3) Compare the two lists
#   4) Return any matches
# 

#   AUTHOR: Emily Levin
#   CREATED: 02/22/25
#   LAST EDITED: 03/23/25

# Clear environment
# rm(list = ls())

library(tinytex)
library(reshape2)
library(ggplot2)
library(grid)
library(gridExtra)
library(ggpubr)
library(lattice)
library(cowplot)
library(MASS)
library(circular)
library(stringr)
library(matrixcalc)
library(pracma)
library(dplyr)
library(lmerTest)
library(tidyverse)
library(brms)
library(viridis)
library(psych)
library(rcompanion)
library(lsr)
library(tinytex)
library(tidyverse)
library(RColorBrewer)
library(nlme)  
library(lme4) 
library(corrplot)
library(rmcorr)
library(cowplot)


setwd('/Users/elevin3/Desktop/Pitt/Research/Derm/Research_Projects/Sunscreen_Allergens/Data/Manuscript_data/')
datadir <- file.path('/Users/elevin3/Desktop/Pitt/Research/Derm/Research_Projects/Sunscreen_Allergens/Data/Manuscript_data/')






# Define the NAC-80 allergen list
nac80_list <- c("1,3-diphenylguanidine", "2-hydroxyethyl methacrylate", 
                "2-mercaptobenzothiazole", "2-n-octyl-4-isothiazolin-3-one", 
                "3-(dimethylamino)-1-propylamine", "4-tert-butylphenolformaldehyde resin", 
                "amidoamine", "amerchol l-101", "ammonium persulfate", 
                "bacitracin", "benzalkonium chloride", "benzisothiazolinone", 
                "benzocaine", "benzophenone-4", "benzyl alcohol", 
                "benzyl salicylate", "black rubber mix", "bromo-2-nitropropane-1,3-diol", 
                "budesonide", "caine mix iii", "carba mix", "chlorhexidine digluconate", 
                "chloroxylenol", "cinnamal", "clobetasol-17-propionate", 
                "cobalt(ii)chloride hexahydrate", "cocamide dea", "cocamidopropyl betaine", 
                "colophonium", "compositae mix ii", "decyl glucoside", 
                "diazolidinyl urea", "dmdm hydantoin", "epoxy resin, bisphenol a", 
                "ethyl acrylate", "ethylenediamine dihydrochloride", "formaldehyde", 
                "fragrance mix i", "fragrance mix ii", "hydroperoxides of limonene", 
                "hydroperoxides of linalool", "hydroxyisohexyl 3-cyclohexene carboxaldehyde", 
                "imidazolidinyl urea", "iodopropynyl butylcarbamate", "lauryl polyglucose", 
                "lanolin alcohol", "lidocaine", "mercapto mix", "methyl methacrylate", 
                "methylisothiazolinone", "methylisothiazolinone+methylchloroisothiazolinone", 
                "methyldibromo glutarinitrile", "mixed dialkyl thiourea", "neomycin sulfate", 
                "nickel(ii)sulfate hexahydrate", "n-isopropyl-n-phenyl-4-phenylenediamine", 
                "oleamidopropyl dimethylamine", "p-phenylenediamine", "paraben mix", 
                "peru balsam", "polymyxin b sulfate", "potassium dichromate", 
                "propyl gallate", "propylene glycol", "propolis", "pramoxine hydrochloride", 
                "quaternium-15", "sesquiterpene lactone mix", "sodium benzoate", 
                "sodium metabisulfite", "sorbitan oleate", "sorbitan sesquioleate", 
                "textile dye mix ii", "tea tree oil oxidized", "thiuram mix", 
                "tixocortol-21-pivalate", "tocopherol", "toluene-2,5-diamine sulfate", 
                "toluenesulfonamide formaldehyde resin", "ylang ylang oil")


# Function to format ingredient names: lowercase, replace spaces with "_", replace "/" with "-"
format_ingredient <- function(ingredient) {
  ingredient <- tolower(ingredient)  # Convert to lowercase
  ingredient <- gsub(" ", "_", ingredient)  # Replace spaces with underscores
  ingredient <- gsub("/", "-", ingredient)  # Replace slashes with hyphens
  return(ingredient)
}


# Function to check sunscreen ingredients against NAC-80
nac80 <- function() {
  
  # ✅ Define variables at the beginning, before processing starts
  full_nac80_matches <- c()
  fragrance_ingredients <- c()
  adjacent_ingredients <- c()
  
  
  # Prompt user for ingredient list
  user_input <- readline(prompt = "\nEnter the sunscreen's ingredients (comma-separated): ")
  
  # Convert input into a list and trim spaces
  user_ingredients <- trimws(unlist(strsplit(user_input, ",")))
  
  # Remove anything inside parentheses along with the parentheses
  user_ingredients <- gsub("\\s*\\(.*?\\)", "", user_ingredients)
  
  # Preserve original capitalization for output
  user_ingredients_lower <- tolower(user_ingredients)
  
  # Find exact NAC-80 matches
  matching_ingredients <- user_ingredients[user_ingredients_lower %in% tolower(nac80_list)]
  
  # Find acrylate-containing ingredients
  acrylate_matches <- user_ingredients[grepl("acrylate", user_ingredients, ignore.case = TRUE)]
  
  
  # Combine NAC-80 and acrylate-containing matches
  full_nac80_matches <- unique(c(matching_ingredients, acrylate_matches))
  
  
  # Normalize Fragrance Mix I and II to also be Fragrance 1 and Fragrance 2
  user_ingredients[user_ingredients_lower == "fragrance mix i"] <- "Fragrance 1"
  user_ingredients[user_ingredients_lower == "fragrance mix ii"] <- "Fragrance 2"
  user_ingredients[user_ingredients_lower == "fragrance 1"] <- "Fragrance Mix I"
  user_ingredients[user_ingredients_lower == "fragrance 2"] <- "Fragrance Mix II"
  
  fragrance_ingredients <- user_ingredients[grepl("fragrance|parfum|perfume|parfume|perfum", 
                                                  user_ingredients, ignore.case = TRUE) & 
                                              !user_ingredients %in% c("Fragrance Mix I", "Fragrance Mix II")]
  
  
  # List of words to extract from "mix" allergens
  mix_related_terms <- c("paraben", "parabens", "rubber", "mercapto", "carba", 
                         "thiourea", "lactone", "caine", "compositae", "textile")
  
  
  # Find adjacent ingredients (including components of "mix" allergens)
  adjacent_ingredients <- user_ingredients[
    grepl("tocopheryl acetate|(^|[^a-z])limonene([^a-z]|$)|(^|[^a-z])linalool([^a-z]|$)|cinnamal", 
          user_ingredients, ignore.case = TRUE) | 
      grepl(paste(mix_related_terms, collapse = "|"), user_ingredients, ignore.case = TRUE) & 
      !grepl("hydroperoxides of linalool|hydroperoxides of limonene", user_ingredients, ignore.case = TRUE) &
      !(tolower(user_ingredients) %in% tolower(nac80_list))  # Exclude exact NAC-80 allergens
  ]
  
  
  # Ensure "tocopherol" is correctly categorized in NAC-80 allergens, not adjacent ingredients
  if ("tocopherol" %in% user_ingredients_lower) {
    matching_ingredients <- unique(c(matching_ingredients, "Tocopherol"))
    adjacent_ingredients <- setdiff(adjacent_ingredients, "Tocopherol")
  }
  
  
  
  # Apply formatting before output
  if (length(full_nac80_matches) > 0) {
    full_nac80_matches <- unique(sapply(full_nac80_matches, format_ingredient))
  }
  if (length(fragrance_ingredients) > 0) {
    fragrance_ingredients <- unique(sapply(fragrance_ingredients, format_ingredient))
  }
  if (length(adjacent_ingredients) > 0) {
    adjacent_ingredients <- unique(sapply(adjacent_ingredients, format_ingredient))
  }
  
  
  
  
  
  # Output results in comma-separated format
  cat("\n--------------------------------------------\n")
  
  if (length(full_nac80_matches) > 0) {
    cat("\n✅ NAC-80 Ingredients Found:\n")
    cat("--------------------------------------------\n")
    cat(paste(full_nac80_matches, collapse = ", "), "\n\n")
  } else {
    cat("\n✅ No NAC-80 ingredients found.\n\n")
  }
  
  
  if (length(fragrance_ingredients) > 0) {
    cat("\n⚠️  Fragrance Ingredients Found:\n")
    cat("--------------------------------------------\n")
    cat(paste(fragrance_ingredients, collapse = ", "), "\n\n")
  } else {
    cat("\n✅ No additional fragrance ingredients found.\n\n")
  }
  
  if (length(adjacent_ingredients) > 0) {
    cat("\n⚠️  Adjacent Ingredients Found:\n")
    cat("--------------------------------------------\n")
    cat(paste(adjacent_ingredients, collapse = ", "), "\n\n")
  } else {
    cat("\n✅ No adjacent-ingredients found.\n\n")
  }
  
  cat("--------------------------------------------\n")
  
  
  # ✅ NEW SECTION: Summary with total allergen count and copy-paste output
  # --------------------------------------------------------
  all_allergens <- unique(c(full_nac80_matches, fragrance_ingredients, adjacent_ingredients))
  
  cat("\n⚠️  Number of Total Allergens Found:\n")
  cat("--------------------------------------------\n")
  cat(length(all_allergens), "\n\n")
  
  if (length(all_allergens) > 0) {
    cat("📝 All Allergens (Copy & Paste):\n")
    cat("--------------------------------------------\n")
    cat(paste(all_allergens, collapse = ", "), "\n\n")
  } else {
    cat("\n✅ No allergens found.\n\n")
  }
  
  
} # end nac80() function





# Run function
nac80()





