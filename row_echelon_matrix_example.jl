points = 10
max_range = 5
min_range = 0
coordinate_matrix = [collect(rand(min_range:max_range, points))'
                                    collect(rand(min_range:max_range, points))']

scatter(coordinate_matrix')

plot(coordinate_matrix[1,:],coordinate_matrix[2,:],
                    seriestype=:scatter,title="My Scatter Plot")

pairwise(Euclidean(), coordinate_matrix, dims=2)



equations = rand(points, points)
equations = Int.(floor.(10 .* equations))
# solutions = rand(points, points)
# solutions = Int.(floor.(10 .* solutions))
solutions = ones(Int, points)

result = \(equations, solutions)
