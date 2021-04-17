using Serialization
using Debugger
using Random
using SparseArrays

irs990extract = deserialize("irs990extract.jldata")
terms = deserialize("terms.jldata")
termfreq = deserialize("termfreq.jldata") # 

irs990extract[1] # First Dict that was extracted from IRS data
size(irs990extract)
row = rand(1:length(irs990extract)) # Generate random row ID; 17855
irs990extract[row]
irs990extract[row]["mission"]

termfreq[row, 1:end] # row of termfreq that corresponds to the [row]th element
findnz(termfreq[row, 1:end])[1] # indeces of words appearing in `row`
terms[findnz(termfreq[row, 1:end])[1]] # words appearing in `row`

row_terms = termfreq[row, 1:end] # sparse vector, only stores elemnts that are non-zero
row_terms.nzind
row_terms.nzval

# Compare words in "mission" to words extracted from doc term matrix
lowercase(join(terms[termfreq[row, 1:end].nzind], " "))
lowercase(irs990extract[row]["mission"])