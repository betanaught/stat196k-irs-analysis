import Random
using MultivariateStats
using Plots
using Distributions

plotly()
SZ = 500, 500

n = 100
x = rand(Normal(), n)
noise_level = 0.3
y = x + noise_level * rand(Normal(), n)
z = x + noise_level * rand(Normal(), n)

scatter(x, y, legend = false, size = SZ)
scatter(x, y, z, legend = false, size = SZ)
scatter!(x=y=z, legend = false, size = SZ)

xy = hcat(x, y) #horizontal concatination
yx = transpose(hcat(x, y))

pca1 = fit(PCA, yx, maxoutdim = 1)
projection(pca1)

xy_trans = transform(pca1, xy)
