---
author: "Brendan Wakefield"
title: "H Assigment - PCA and Cluster Analysis"
date: "19 April 2021"
---


# Exploratory Data Analysis
```julia
using Serialization
using Statistics, StatsBase, Random
using MultivariateStats
using Debugger

irs990extract = deserialize("../processed990/irs990extract.jldata")
terms = deserialize("../processed990/terms.jldata")
termfreq = deserialize("../processed990/termfreq.jldata")
```

260783×79653 SparseArrays.SparseMatrixCSC{Float64, Int64} with 5663744 stored entries:
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿




1. __Relatively how many terms appear in exactly one document?__
```julia
single_terms_ind = [length(termfreq[:,i].nzval)==1 for i in 1:length(terms)]
single_terms = terms[single_terms_ind]
100 * (length(single_terms)/length(terms))
```

```
61.292104503282985
```




About 60% of terms appear in only one IRS record.

2. __Relatively how many terms appear at least 5 times?__
```julia
five_terms_ind = [length(termfreq[:,i].nzval)>=5 for i in 1:length(terms)]
five_terms = terms[five_terms_ind]
100 * (length(five_terms)/length(terms))
```

```
17.871266618959737
```




About 18% of terms appear in at lease 5 of the IRS records.

3. __Show the 20 most frequent words. Words like “and”, “to”, “the” aren’t especially meaningful. Which is the first word that you feel may be meaningful for characterizing the nonprofit? Why?__
```julia
sum(termfreq[2:end, 1].nzval)
sum(termfreq[1:end, 2].nzval)
sort([sum(termfreq[1:end, i].nzval) for i in 1:79653], rev = true)
terms_top20 = sortperm([sum(termfreq[1:end, i].nzval) for i in 1:79653],
                        rev = true)[1:20]
```

```
20-element Vector{Int64}:
  6298
 72116
 71195
 52172
 58980
 28470
 35797
 23768
  3122
 17116
 65249
 37655
 58693
 53295
 69565
 50814
 77999
 64701
 34296
 71748
```




The top 20 most frequent words are:
```julia
show(terms[terms_top20])
```

```
["and", "to", "the", "of", "provid", "for", "in", "educ", "a", "communiti",
 "servic", "is", "promot", "organ", "support", "none", "with", "see", "hous
", "through"]
```




The top 20 most frequent *meaningful* words (without "and", "to", "the", etc.) are:
```julia
terms_top40 = sortperm([sum(termfreq[1:end, i].nzval) for i in 1:79653],
                        rev = true)[1:40]
interesting_words = terms[terms_top40]
boring_words = ["and", "to", "the", "of", "for", "in", "a", "is", "by", "o",
                "that", "our", "as"]

top20_interesting_words = setdiff(interesting_words, boring_words)[1:20]
show(top20_interesting_words)
```

```
["provid", "educ", "communiti", "servic", "promot", "organ", "support", "no
ne", "with", "see", "hous", "through", "member", "program", "develop", "car
e", "schedul", "mission", "health", "school"]
```




We see many community-oriented and support words such as service, provide, promote, support, health, school. These words are consistent with many of the themes I would expect to find in the mission descriptions of non-profit organizations.

4. __How many documents contain “sacramento”?__
```julia
sum([occursin("sacramento", lowercase(irs990extract[i]["mission"]))
    for i in 1:length(irs990extract)])
```

```
155
```




155 of the IRS nonprofit mission statements include the word "sacramento."

5. __What’s one element in irs990extract where the mission contains “sacramento”?__
```julia
sac_ind = [occursin("sacramento", lowercase(irs990extract[i]["mission"]))
    for i in 1:length(irs990extract)]
sum(sac_ind)
sac_pub_lib_found = irs990extract[sac_ind][1]
sac_pub_lib_found["mission"]
sac_pub_lib_found["name"]
```

```
"Sacramento Public Library Foundation"
```




The first mission statement to contain the word "sacramento" in my analysis is
the "Sacramento Public Library Foundation"

6. __Come up with your own question similar to the questions above, and answer it.__
I was curious to know the average number of words in all the mission descriptions.
```julia
mean([length(irs990extract[i]["mission"]) for i in 1:length(irs990extract)])
```

```
189.55100217422148
```




On average, there are just under 200 words in each mission statement.

# Selecting a Subset

1. __Use one or more of the fields in `irs990extract` to define and pick the 10,000 largest nonprofits.__
```julia
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

subsample = termfreq[employee_top10k, 1:end]
sort(subsample[1,:])
```

```
79653-element SparseArrays.SparseVector{Float64, Int64} with 25 stored entr
ies:
  [79629]  =  0.0333333
  [79630]  =  0.0333333
  [79631]  =  0.0333333
  [79632]  =  0.0333333
  [79633]  =  0.0333333
  [79634]  =  0.0333333
  [79635]  =  0.0333333
           ⋮
  [79646]  =  0.0333333
  [79647]  =  0.0333333
  [79648]  =  0.0333333
  [79649]  =  0.0333333
  [79650]  =  0.0666667
  [79651]  =  0.0666667
  [79652]  =  0.0666667
  [79653]  =  0.1
```





2. __What’s the largest nonprofit based on your definition? Does it seem reasonable?__
```julia
# Largest organization by number of employees
irs990extract[employee_top10k][1]
irs990extract[employee_top10k][1]["name"]
irs990extract[employee_top10k][1]["mission"]
```

```
"We provide services to disabled individuals. In addition, we provide food,
 shelter, love, clothing and social interaction for our clients; we accomod
ate between 10 to 14 individuals of all ages."
```




After sorting the organizations by number of employees (and keeping the top 10,000), the largest organization I found was the "Worrell & Mitchel Group Home Inc." I looked this organization up online, and I can't tell if this completely makes sense. There is no website for the group home, only other sites containing reviews of it. It's hard for me to believe an organization with > 200,000 employees would *not* have a website. But, I looked at the top 10 organizations by employee number and found others that did make sense (such as the Kaiser Hospital Foundation (but I did notice they had two records for the same EIN, legal?).

3. __Drop all the words that don't appear at least twice in the subset.__
```julia
double_terms_ind = [length(subsample[:,i].nzval) >= 2 for i in 1:size(subsample, 2)]
subsample = subsample[:, double_terms_ind]
```

```
10000×4859 SparseArrays.SparseMatrixCSC{Float64, Int64} with 289136 stored 
entries:
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
```





# Principal Component Analysis
1. __Interpret the principal ratio. What does it mean?__
```julia
subsample
transpose(subsample)
subsample_transpose = collect(transpose(subsample))
pca1 = fit(PCA, subsample_transpose, maxoutdim = 10)
```

```
PCA(indim = 4859, outdim = 10, principalratio = 0.47382585032743996)
```




The principal ratio describes how much of the heterogeneity in the data is explained by the first 10 principal components. Here, we see that the first 10 PCs account for about 50% of the variance in the data. Fitting the model with 3 and 20 PCs resulted in ratios of 0.34 and 0.56, respectively, so it's nice to know that 10 dimensions accounts for much more variance than 3, but doubling the number of PCs does not inprove the quality of our model by much. It's very cool knowing we reduced the matrix from 80,000 dimensions and can still explain almost half the variance in the data.
```julia
# Principal Ratio
principalratio(pca1)
pca1.prinvars # Variance of each PC
sum(pca1.prinvars)/pca1.tvar # Same as principalratio(pca1)
```

```
0.47382585032743996
```





2. __Plot the variances of the first 10 principal components as a function of the principal component number. What do you observe?__
```julia
using Plots
scatter(pca1.prinvars, legend = false)
```

![](figures/clustering_15_1.png)


It looks like the first principal component contains much more variance than the others, which are all quite similar.

3. __Which words have the relatively largest loadings in the first principal component? (These the absolute values of the entries of projection().) Are these the kinds of words you expected? Explain.__
```julia
pca1.proj[:,1]  # word indicies (rows) of the first principal component
abs.(pca1.proj[:,1])
loaded_words = sortperm(abs.(pca1.proj[:,1]), rev = true)
show(terms[loaded_words][1:100])
```

```
["acquisit", "aacp", "acon", "136115884", "adorn", "administrativedisciplin
ari", "aafmaa", "acadia", "actionadministr", "5612101", "2008", "50034", "1
1510", "1857", "616055994", "402", "afocr", "aark", "301", "1826", "acc", "
affilia", "adopopt", "abili", "739", "administratorservic", "8702", "271", 
"actiiv", "561", "374", "573", "administrationth", "adenoid", "1309", "7152
357793", "academichealthculturalsoci", "147", "academicvoc", "abim", "1930"
, "941375814", "6191", "aaoa", "5006003", "2615", "81974", "1425", "addicti
onvictim", "activitiessupport", "adair", "15059", "26150", "135000", "aapt"
, "816", "189", "12300", "53", "352213", "aamva", "20012010", "52000", "500
0", "1624", "abct", "5700", "8240", "562", "acord", "afraid", "504", "2017"
, "accur", "afghan", "aamg", "adolesc", "adultchild", "affilpubl", "3142", 
"3150", "322", "250000", "00", "330075", "2250", "aeolian", "230", "18146",
 "5080", "119", "affiliti", "15", "advocacyto", "19382017", "592", "696", "
146", "adin", "2028"]
```




These are not the types of words I would have initially expected to have the relatively largest loadings in the first principal componenet, because, naively, I would have thought that unique and particularly meaningful words would be the most "important." However, after reflecting more on what words would "load" a principal component, I think actually it would make sense for awkward and strange words to "load" the PC most (have the highest variance). I'm thinking of something similar to (if not the same as) "leverage points" in regression; these are often outliers that have large residuals that "pull" hardest on the regression model, and I think this might be what's happening here. That would explain why the loading points are a bit strange (and many are numbers).

# Clustering

1. __How many elements are in each group?__
```julia
import Clustering

ten_space = transform(pca1, subsample_transpose) # use this for clustering
# Data subsample projected into 10-dimensional subspace
nclusters = 3
k3 = Clustering.kmeans(ten_space, nclusters)

group1 = k3.assignments .== 1
group2 = k3.assignments .== 2
group3 = k3.assignments .== 3

[sum(group1), sum(group2), sum(group3)]
```

```
3-element Vector{Int64}:
  460
 5375
 4165
```




The three groups have 5375, 4165, and 460 organizations, respectively.

2. __Which nonprofits are closest to the centroids? Feel free to use the function below.__
```julia
function close_centroids(knn_model)
    groups = knn_model.assignments
    k = length(unique(groups))
    n = length(groups)
    result = fill(0, k)
    for ki in 1:k
        cost_i = fill(Inf, n)
        group_i = ki .== groups
        cost_i[group_i] = knn_model.costs[group_i]
        result[ki] = argmin(cost_i)
    end
    result
end

## Organizations closest to the centroids
centroid_orgs = close_centroids(k3)
irs990extract[employee_top10k][centroid_orgs]
[irs990extract[employee_top10k][i]["name"] for i in centroid_orgs]
```

```
3-element Vector{String}:
 "UPMC GROUP"
 "INCLUSA INC"
 "JC BLAIR MEMORIAL HOSPITAL"
```




The three nonprofits closest to the cluster centroids Inclusa Inc, JC Blair Memorial Hospital, and UPMC Group.

3. __k means should find a group of mission statements that are very similar. What happened? Is it reasonable? If we were to continue this analysis, what would you do next?__
```julia
irs990extract[employee_top10k][group1]
irs990extract[employee_top10k][group2]
irs990extract[employee_top10k][group3]

[irs990extract[employee_top10k][group1][i]["name"] for i in 1:sum(group1)]
[irs990extract[employee_top10k][group2][i]["name"] for i in 1:sum(group2)]
[irs990extract[employee_top10k][group3][i]["name"] for i in 1:sum(group3)]
```

```
4165-element Vector{String}:
 "CITY GARDEN WALDORF SCHOOL"
 "KAISER FOUNDATION HOSPITALS"
 "KAISER FOUNDATION HOSPITALS"
 "HCR MANORCARE INC"
 "PARTNERS HEALTHCARE SYSTEM INC &"
 "THE CLEVELAND CLINIC FOUNDATION"
 "TRUSTEES OF THE UNIVERSITY OF PENNSYLVANIA"
 "TRUSTEES OF THE UNIVERSITY OF PENNSYLVANIA"
 "MHM SUPPORT SERVICES"
 "IHC HEALTH SERVICES INC"
 ⋮
 "Awana Clubs International"
 "LUTHERAN RETIREMENT CENTER ASSOCIATION"
 "ST ANN CENTER FOR"
 "Oklahoma Methodist Manor Inc"
 "SKIDAWAY HEALTH AND LIVING SERVICES INC"
 "CHILEDA INSTITUTE INC"
 "AMERICAN LIBRARY ASSOCIATION"
 "ARIZONA RETIREMENT CENTERS INC"
 "NORTHEAST OHIO NEIGHBORHOOD HEALTH"
```




I noticed that while looking for characteristics of the nonoprofits in the clusters, group1 contains several hospitals, medical groups, and care homes, group2 is fairly similar but a seeming mix of medical and educational groups, and
group3 contains many universities. It would make sense that group1 and group3 might be more polarized with group2 containing a "mix" or organizations (perhaps something in the writing of the mission statements makes this the "middle" group). I also noticed that several of the nonprofits in group2 have the word 'trustee' in their names, which most likely contain similar words in their mission statements.

If I were to continue the analysis, I would want to first determine if my initial observations of the groups were accurate; I'd spend some more time investigating the types of organizations in the groups to see if I could extract the characteristics of the nonprofits in each group that set them apart. Then, I might try to perform some form of regression to see if I could genereate regression coefficients on these characteristics as predictor variables in an attempt to quantify their influence on what determines which group a nonprofit belongs to. For example, I might be able to use more of the quantitative data from the 990 forms (like revenue, number of volunteers, etc.) as predictor variables in a mulitnomial logistic regression and use the regression coefficients to describe the relative magnitudes of these variables' impacts.

# ------------------------------------------------------------------------------
# Julia Code
```julia
using Serialization
using Statistics, StatsBase, Random
using MultivariateStats
using Debugger

# irs990extract = deserialize("irs990extract.jldata")
# terms = deserialize("terms.jldata")
# termfreq = deserialize("termfreq.jldata")

"""
    Exploratory Data Analysis --------------------------------------------------
"""
# 1. Relative proportion of words eapearing in only 1 document -----------------
single_terms_ind = [length(termfreq[:,i].nzval)==1 for i in 1:length(terms)]
single_terms = terms[single_terms_ind]
100 * (length(single_terms)/length(terms))

# 2. Relative proportion of words eapearing in at least 5 documents ------------
five_terms_ind = [length(termfreq[:,i].nzval)>=5 for i in 1:length(terms)]
five_terms = terms[five_terms_ind]
100 * (length(five_terms)/length(terms))

StatsBase.counts(termfreq[1,:].nzind)

# 3. 20 most frequent words ----------------------------------------------------
# Sort terms in termfreq by usage (total freq)
sum(termfreq[2:end, 1].nzval)
sum(termfreq[1:end, 2].nzval)
sort([sum(termfreq[1:end, i].nzval) for i in 1:79653], rev = true)
terms_top20 = sortperm([sum(termfreq[1:end, i].nzval) for i in 1:79653],
                        rev = true)[1:20]
# What are they?
show(terms[terms_top20])
# Let's get rid of "and", "to", "for", etc.
terms_top40 = sortperm([sum(termfreq[1:end, i].nzval) for i in 1:79653],
                        rev = true)[1:40]
interesting_words = terms[terms_top40]
boring_words = ["and", "to", "the", "of", "for", "in", "a", "is", "by", "o",
                "that", "our", "as"]

top20_interesting_words = setdiff(interesting_words, boring_words)[1:20]
show(top20_interesting_words)

# 4. Number of records with "sacramento" ---------------------------------------
sum([occursin("sacramento", irs990extract[i]["mission"])
    for i in 1:length(irs990extract)])
sum([occursin("Sacramento", irs990extract[i]["mission"])
    for i in 1:length(irs990extract)])
sum([occursin("sacramento", lowercase(irs990extract[i]["mission"]))
    for i in 1:length(irs990extract)])


# 5. One record containing "sacramento" ----------------------------------------
sac_ind = [occursin("sacramento", lowercase(irs990extract[i]["mission"]))
    for i in 1:length(irs990extract)]
sum(sac_ind)
sac_pub_lib_found = irs990extract[sac_ind][1]
sac_pub_lib_found["mission"]
sac_pub_lib_found["name"]


lowercase(join(terms[termfreq[1, 1:end].nzind], " "))

# 6. Average number of words per document? -------------------------------------
rand_irs_elements = rand(1:length(irs990extract), 10)
[length(irs990extract[i]["mission"]) for i in rand_irs_elements] # 
mean([length(irs990extract[i]["mission"]) for i in 1:length(irs990extract)])

"""
    Selecting a Subset ---------------------------------------------------------
"""
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

# Largest organization by number of employees
irs990extract[employee_top10k][1]
irs990extract[employee_top10k][1]["name"]
irs990extract[employee_top10k][1]["mission"]
irs990extract[employee_top10k][2]
irs990extract[employee_top10k][3]
irs990extract[employee_top10k][4]
irs990extract[employee_top10k][5]

subsample = termfreq[employee_top10k, 1:end]
sort(subsample[1,:])

double_terms_ind = [length(subsample[:,i].nzval) >= 2 for i in 1:size(subsample, 2)]
subsample = subsample[:, double_terms_ind]

"""
    Principal Component Analysis -----------------------------------------------
"""
using Plots

subsample
transpose(subsample)
subsample_transpose = collect(transpose(subsample))
pca1 = fit(PCA, subsample_transpose, maxoutdim = 10)
# PCA(indim = 4859, outdim = 10, principalratio = 0.47382585032743996)
# First 10 PCs account for ~ 50% of the variance
pca2 = fit(PCA, subsample_transpose, maxoutdim = 20)
# Next 10 PCs (20 total, 0.56) explain only ~ 8% more variance
pca3 = fit(PCA, subsample_transpose, maxoutdim = 3)

# Principal Ratio
principalratio(pca1)
pca1.prinvars # Variance of each PC
sum(pca1.prinvars)/pca1.tvar # Same as principalratio(pca1)

# scatter(transpose(pca1.proj), legend = false) #Looks like this plots residuals
scatter(pca1.prinvars, legend = false)

# Words with largest loadings from first component will have largest residuals
# (need absolute value)
pca1.proj[:,1] # word indicies (rows) of the first principal component
abs.(pca1.proj[:,1])
loaded_words = sortperm(abs.(pca1.proj[:,1]), rev = true)
show(terms[loaded_words][1:100])

"""
    Cluster Analysis -----------------------------------------------------------
"""
import Clustering

ten_space = transform(pca1, subsample_transpose) # use this for clustering
# Data subsample projected into 10-dimensional subspace
nclusters = 3
k3 = Clustering.kmeans(ten_space, nclusters)

group1 = k3.assignments .== 1
group2 = k3.assignments .== 2
group3 = k3.assignments .== 3

[sum(group1), sum(group2), sum(group3)]

function close_centroids(knn_model)
    groups = knn_model.assignments
    k = length(unique(groups))
    n = length(groups)
    result = fill(0, k)
    for ki in 1:k
        cost_i = fill(Inf, n)
        group_i = ki .== groups
        cost_i[group_i] = knn_model.costs[group_i]
        result[ki] = argmin(cost_i)
    end
    result
end

## Organizations closest to the centroids
centroid_orgs = close_centroids(k3)
irs990extract[employee_top10k][centroid_orgs]
[irs990extract[employee_top10k][i]["name"] for i in centroid_orgs]

irs990extract[employee_top10k][group1]
irs990extract[employee_top10k][group2]
irs990extract[employee_top10k][group3]

[irs990extract[employee_top10k][group1][i]["name"] for i in 1:sum(group1)]
[irs990extract[employee_top10k][group2][i]["name"] for i in 1:sum(group2)]
[irs990extract[employee_top10k][group3][i]["name"] for i in 1:sum(group3)]
```

```
["and", "to", "the", "of", "provid", "for", "in", "educ", "a", "communiti",
 "servic", "is", "promot", "organ", "support", "none", "with", "see", "hous
", "through"]["provid", "educ", "communiti", "servic", "promot", "organ", "
support", "none", "with", "see", "hous", "through", "member", "program", "d
evelop", "care", "schedul", "mission", "health", "school"]Error: cannot doc
ument the following expression:

using Plots
```


