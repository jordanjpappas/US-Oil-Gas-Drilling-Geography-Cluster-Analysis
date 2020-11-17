# Stylized Trends in 21st Century US Onshore Oil and Gas Drilling Geography from Cluster Analysis
* Disclaimer: This analysis is currently preliminary and pending publication.

<br /> • Study geographic development of oil and gas industry across US using cluster finite mixture models fit to county-level time series data.
<br /> • Imported natural gas data in CSV format containing 1 million rows. Write R scripts to clean data using packages like dplyr, reshape2, tidyverse.
<br /> • Apply machine learning algorithms such as finite mixture and clustering models using FlexMix package.
<br /> • Prepare research paper for publication using ggplot2, Microsoft Word.


![GitHub last commit](https://img.shields.io/github/last-commit/jordanjpappas/Oil_Gas_Cluster_Analysis)

![GitHub issues](https://img.shields.io/github/issues-raw/jordanjpappas/Oil_Gas_Cluster_Analysis)

![GitHub pull requests](https://img.shields.io/github/issues-pr/jordanjpappas/Oil_Gas_Cluster_Analysis)

![GitHub all releases](https://img.shields.io/github/downloads/jordanjpappas/Oil_Gas_Cluster_Analysis/total):

![GitHub](https://img.shields.io/github/license/jordanjpappas/Oil_Gas_Cluster_Analysis)



# Demo-Preview



# Table of contents

- [Project Title](#project-title)
- [Demo-Preview](#demo-preview)
- [Table of contents](#table-of-contents)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contribute](#contribute)
    - [Sponsor](#sponsor)
    - [Adding new features or fixing bugs](#adding-new-features-or-fixing-bugs)
- [License](#license)
- [Footer](#footer)

# Installation
[(Back to top)](#table-of-contents)




# Usage
[(Back to top)](#table-of-contents)

- init-jordan.R: Load packages and set directory hidden objects.
- 00-collectwelldata.R: Import drilling data, filter by production types (i.e. 'OIL & GAS','GAS','OIL','GAS OR COALBED','CBM'), and aggregate data to county-year level.
- 01-convert_BOE.R: Convert drilling data to barrels of oil (BOE) production data.
- 1a-run_mixedmodels.R: Apply cluster finite mixture models to drilling data and plot various time-series cluster model outputs.
- 1b-run_mixedmodels_BOE.R: Apply cluster finite mixture models to production data and plot various time-series cluster model outputs.
- 2a-plot_sum_of_squares.py: Calculate sum of squares measure for various cluster model outputs and plot scree visualization.
- 2b-map_states.R: Plot various state geography cluster model outputs.
- 2c-map_shale_plays.R: Plot various shale play geography cluster model outputs.
- 3-calculate_summ_stats.py: (pending)
- 4a-construct_county_shares.R: Construct state-level dataset that counts number of counties in each cluster by state.
- 4b-construct_play_shares.R: Construct play-level dataset that counts number of counties in each cluster by state.
- 5-compare_weighted_unweighted_approach.R: Compare unweighted and weighted approach cluster results.
- 6-compare_data_distributions.R: Create dataset of counties with a categorical variable for drilling vs. production data missingness. Plot state geography cluster missigness results.
- 99-compile-docx.R: Compile previous script outputs into Microsoft Word .docx format.



# Development
[(Back to top)](#table-of-contents)




# Contribute
[(Back to top)](#table-of-contents)






### Adding new features or fixing bugs
[(Back to top)](#table-of-contents)




# License
[(Back to top)](#table-of-contents)





# Footer
[(Back to top)](#table-of-contents)

