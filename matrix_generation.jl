using Plots
   using LinearAlgebra
   using Images
   using Distances
   using Images
   using JLD

julia_func_path = "../julia-functions/"
   include(julia_func_path*"MatrixToolbox.jl")
   include(julia_func_path*"MatrixProcessing.jl")
   include(julia_func_path*"BettiCurves.jl")
   include(julia_func_path*"ImageProcessing.jl")
   include(julia_func_path*"PlottingWrappers.jl")

debug = true

 if debug
    ENV["JULIA_DEBUG"] = "all"
 end

image_size = 64

img_0 = zeros(Gray, image_size, image_size)

img1 = copy(img_0)

upper_diag_elem_num = Int.(((image_size-1)*(image_size))/2)
matrix_indices = findall(x->x>=0, UpperTriangular(img1))

row = 1
col = 1
max_col = image_size
for ind in 1:upper_diag_elem_num
   global row, col, max_col
   img1[row, col] = ind/upper_diag_elem_num
   col +=1
   if col>=max_col
      col=1
      row+=1
      max_col -= 1
   end
end


img1



# ==============================================================================
# ============ Saving images ===================================================
save_path = "../matrix-generation/img"
save(save_path*"gradient.png",img1)
