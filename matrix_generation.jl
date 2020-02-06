using Plots
   using LinearAlgebra
   using Images
   using Distances
   using Images
   using JLD

julia_func_path = "./julia-functions/"
   include(julia_func_path*"MatrixToolbox.jl")
   include(julia_func_path*"MatrixProcessing.jl")
   include(julia_func_path*"BettiCurves.jl")
   include(julia_func_path*"ImageProcessing.jl")
   include(julia_func_path*"PlottingWrappers.jl")

debug = true

 if debug
    ENV["JULIA_DEBUG"] = "all"
 end

image_size = 80

img_0 = zeros(Float64, image_size, image_size)

# Get all cartesian indices from input matrix
matrix_indices = CartesianIndices((1:image_size, 1:image_size))
# Filter out indices below diagonal
matrix_indices = findall(x->x[1]>x[2], matrix_indices)

# Put evrything together
# how many elements are above diagonal
upper_diag_elem_num = Int.(((image_size-1)*(image_size))/2)

for k=1:upper_diag_elem_num
    # next_position = matrix_indices[k]
    matrix_index = matrix_indices[k]
    value = matrix_index[1]
    img_0[matrix_index] += 1
    img_0[matrix_index[2], matrix_index[1]] += 1
end
issymmetric(Float64.(img_0))

Gray.(img_0./image_size)

max_val = 5.
row_skip = 0
# col_skip = 2
strip_size = 2
factor = 0.8

leaving = 1
skipping = 1
rows = collect(1:image_size)
for elements = 1:image_size
   global leaving, skipping
   if leaving <= strip_size
      skipping = 0
      leaving +=1
   elseif skipping < row_skip
      rows[elements] = -1
      skipping +=1
   else
      leaving =0
   end
end
rows = rows[findall(x->x>0,rows)]



img_0 = zeros(Float64, image_size, image_size)
for row in rows
   value = rand(1:max_val)
   for iterations = rows

      if row < iterations
         img_0[row, iterations] += value
      else
         img_0[iterations, row] += value
      end
   end
end

for row in rows
   img_0[row, row] += factor * findmax(img_0[row,:])[1]
end

img1 = Gray.(img_0'./findmax(img_0)[1])

symmetrize_image(img1)






# ==============================================================================
# ============ Saving images ===================================================
save_path = "../matrix-generation/img/"

save(save_path*"multi_stripes.png",img1)
