using Serialization
using Statistics, StatsBase, Random
using MultivariateStats
using Debugger

irs990extract = deserialize("irs990extract.jldata")
terms = deserialize("terms.jldata")
termfreq = deserialize("termfreq.jldata")

#### Exploratory Data Analysis -------------------------------------------------
# 1. Relative number of words per document
rand_irs_elements = rand(1:length(irs990extract), 30)
[length(irs990extract[i]["mission"]) for i in rand_irs_elements] # 
mean([length(irs990extract[i]["mission"]) for i in 1:length(irs990extract)])

length(termfreq[1111,:].nzval)/length(terms) # proportion of terms for each doc
## Not quite, we want proportion of terms that show up in only 1 doc
## terms that show up in only one document
single_terms_ind = [length(termfreq[:,i].nzval)==1 for i in 1:length(terms)]
single_terms = terms[single_terms_ind]
length(single_terms)/length(terms)

five_terms_ind = [length(termfreq[:,i].nzval)>=5 for i in 1:length(terms)]
five_terms = terms[five_terms_ind]
length(five_terms)/length(terms)

StatsBase.counts(termfreq[1,:].nzind)

# 3. 
# Sort terms in termfreq by usage (total freq)
sum(termfreq[2:end, 1].nzval)
sum(termfreq[1:end, 2].nzval)
sort([sum(termfreq[1:end, i].nzval) for i in 1:79653], rev = true)
terms_top20 = sortperm([sum(termfreq[1:end, i].nzval) for i in 1:79653], rev = true)[1:20]
terms[terms_top20]

# 4. Number of records with "sacramento"
sum([occursin("sacramento", irs990extract[i]["mission"]) for i in 1:length(irs990extract)])
sum([occursin("Sacramento", irs990extract[i]["mission"]) for i in 1:length(irs990extract)])

# try;
lowercase(join(terms[termfreq[1, 1:end].nzind], " "))


### Selecting a Subset ---------------------------------------------------------
# 1. Pick 10,000 largest orgs using "employees"

parse(Int, irs990extract[1]["employees"])

function parse_employees(x)
    emp = x["employees"]
    if ismissing(emp)
        0
    else
        parse(Int, emp)
    end
end

employee_tally = map(parse_employees, irs990extract)
employee_top10k = sortperm(employee_tally, rev = true)[1:10_000]
irs990extract[employee_top10k]
irs990extract[employee_top10k][1]["mission"]

termfreq[employee_top10k, 1:end]

sample_matrix = transpose(termfreq[employee_top10k, 1:end])

pca1 = fit(PCA)