# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu





# Load data

setwd(.rt_data)

'yearrlylycountyprod19902020.dta' %>% haven::read_dta() -> countyprod
countyprod %<>% filter(year>=2000, year<=2019)



# Convert data to BOE

countyprod %<>% mutate(
  BOE = countyyearlyoil + (countyyearlygas/5.8)
)
countyprod %<>% select(county_id,year,BOE)

saveRDS(countyprod, 'countyprod.rds')

