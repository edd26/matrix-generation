using Eirene
 using Plots
    using LinearAlgebra
    using Images
    using Distances
    using Images
    using JLD

    julia_func_path = "../image-topology/julia-functions/"
     include(julia_func_path*"MatrixToolbox.jl")
     include(julia_func_path*"MatrixProcessing.jl")
     include(julia_func_path*"BettiCurves.jl")
     include(julia_func_path*"ImageProcessing.jl")
     include(julia_func_path*"PlottingWrappers.jl")

debug = true

 if debug
    ENV["JULIA_DEBUG"] = "all"
 end

# ==============================================================================
# =============================== Set parameters ===============================

plot_heatmaps = true
save_heatmaps = false
plot_betti_figrues = true
do_eirene = true
max_size_limiter = 80

result_path = "results/"
     gabor_path = result_path*"gabor/"
     figure_path = result_path*""
     heatmaps_path = figure_path*"heatmaps/"

     img_path = "img/"
     simple_matrix_path = img_path*""

     cd("../matrix-generation/")
# ==============================================================================
# ================================== Get Image =================================
file_dict = Any[];
  file_names = readdir(simple_matrix_path)
  push!(file_dict, file_names)

# ==============================================================================
# ============================== Loop over images ==============================
images_set = file_dict[1]

file_name = images_set[2]
get_curves_from_matrix(file_name)

# ======================
file_n = split(file_name, ".")[1]
img1_gray = Gray.(load(simple_matrix_path*file_name))
img_size = size(img1_gray)
image_size = img_size[1]


img1 = copy(img1_gray)

# ====
function symmetrize(image)
  mat_size = size(image,1)

  img= copy(image)
  # Get all cartesian indices from input matrix
  matrix_indices = CartesianIndices((1:mat_size, 1:mat_size))
  # Filter out indices below diagonal
  matrix_indices = findall(x->x[1]>x[2], matrix_indices)

  # Put evrything together
  # how many elements are above diagonal
  repetition_number = Int(ceil((mat_size * (mat_size-1))/2))


  # Get all values which will be sorted
  sorted_values = input_matrix[matrix_indices]

  # Sort indices by values (highest to lowest)
  ordered_indices = sort!([1:repetition_number;],
                      by=i->(sorted_values[i],matrix_indices[i]))

  for k=1:repetition_number
      # next_position = matrix_indices[k]
      matrix_index = matrix_indices[k]
      # ordered_matrix[matrix_index] = k
      img[matrix_index[2], matrix_index[1]] = img[matrix_index]
  end
  issymmetric(Float64.(img))
  return img
end

# ======================

function get_curves_from_matrix(file_name)
  size_limiter = max_size_limiter

  file_n = split(file_name, ".")[1]
  img1_gray = Gray.(load(simple_matrix_path*file_name))
  img1_gray = symmetrize_image(img1_gray)
  img_size = size(img1_gray)

  C_ij = Float64.(img1_gray)

  # ==============================================================================
  # =============================== Ordered matrix ===============================
  if size_limiter > size(C_ij,1)
    @warn "Used size limiter is larger than matrix dimension: " size_limiter size(C_ij,1)
    @warn "Using maximal size instead"
    size_limiter = size(C_ij,1)
  else
    size_limiter = max_size_limiter
  end

  ordered_matrix = get_ordered_matrix(C_ij[1:size_limiter, 1:size_limiter])

  # ==============================================================================
  # ============================ Persistance homology ============================
  C = eirene(ordered_matrix,maxdim=3,model="vr")


  # ==============================================================================
  # ================================ Plot results ================================

  if plot_heatmaps

    full_ordered_matrix= get_ordered_matrix(C_ij)
    heat_map2 = plot_square_heatmap(full_ordered_matrix, 10, 80;
            plt_title = "Order matrix of $(file_n)")

    if save_heatmaps
        heatm_details = "_heatmap_$(file_n)"
        savefig(heat_map2, heatmaps_path*"ordering"*heatm_details)
    end
  end

  if plot_betti_figrues && do_eirene
    plot_title = "Betti curves of $(file_n), n=$(size_limiter) "
    figure_name = "betti_$(file_n)_n$(size_limiter)"
    ref = plot_and_save_bettis(C, plot_title, figure_path; file_name=figure_name,
                                    do_save=true, extend_title=false,
    								do_normalise=false, max_dim=3,legend_on=true,
                                    min_dim=1)
  end
  display(img1_gray)
  display(heat_map2)
  display(ref)
end
