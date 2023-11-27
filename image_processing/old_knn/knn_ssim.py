import cv2
import os
import numpy as np
from skimage.metrics import structural_similarity as ssim

# old version


def crop_and_patch_image(image_path, crop_size, patch_size):
    # Load the image
    image = cv2.imread(image_path)
    
    # Check if image is loaded
    if image is None:
        print(f"Error: Failed to load image '{image_path}'")
        return []
    
    # Crop the image to the desired size (1000x800)
    if image.shape[0] < crop_size[1] or image.shape[1] < crop_size[0]:
        print(f"Error: Image size is smaller than the desired crop size")
        return []
    
    # Assuming we want to crop from the top-left corner, adjust if needed
    cropped_image = image[:crop_size[1], :crop_size[0]]
    
    # List to hold the patches
    patches = []

    # Extract patches from the cropped image
    for y in range(0, cropped_image.shape[0], patch_size[1]):
        for x in range(0, cropped_image.shape[1], patch_size[0]):
            patch = cropped_image[y:y + patch_size[1], x:x + patch_size[0]]
            patches.append(patch)
    
    return patches

def load_known_patches(directory_path):
    patch_files = [f for f in os.listdir(directory_path) if f.endswith('.jpg')]
    patches = []
    for file in patch_files:
        file_path = os.path.join(directory_path, file)
        patch = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
        if patch is not None:
            patches.append((patch, file))  # Append the patch along with its filename
        else:
            print(f"Warning: Unable to load image at {file_path}")
    return patches

def analyze_edges(patches, low_threshold, high_threshold):
    edge_maps = []
    for patch in patches:
        if patch.ndim == 3 and patch.shape[2] == 3:
            # Convert patch to grayscale
            gray_patch = cv2.cvtColor(patch, cv2.COLOR_BGR2GRAY)
        else:
            # If the image is already one channel, assume it is grayscale
            gray_patch = patch
        # Detect edges in the patch
        edges = cv2.Canny(gray_patch, low_threshold, high_threshold)
        edge_maps.append(edges)
    return edge_maps

def calculate_ssim(input_edge_maps, known_edge_maps):
    # Stores a list of SSIM scores along with the indices of the patches compared
    ssim_scores = []

    # Iterate over each combination of edge maps
    for index1, em1 in enumerate(input_edge_maps):
        for index2, em2 in enumerate(known_edge_maps):
            score = ssim(em1, em2)
            ssim_scores.append((index1, index2, score))
    return ssim_scores

def knn_ssim(ssim_scores, k):
    # Sort the SSIM scores for each input patch
    knn_results = {}
    for score_data in ssim_scores:
        input_patch_index = score_data[0]
        if input_patch_index not in knn_results:
            knn_results[input_patch_index] = []
        knn_results[input_patch_index].append(score_data)
    
    # K nearest neighbors
    for patch_index in knn_results:
        knn_results[patch_index] = sorted(knn_results[patch_index], 
                                          key=lambda x: x[2], reverse=True)[:k]

    return knn_results

def label_patches(knn_results, labels, threshold, 
                  output_file):
    with open(output_file, 'w') as file:
        for input_patch_index, neighbors in knn_results.items():
            file.write(f"Input Patch {input_patch_index+1} is most similar to:\n")
            for neighbor in neighbors:
                known_patch_index, ssim_score = neighbor[1], neighbor[2]
                # Retrieve label of the most similar known patch
                patch_label = labels[known_patch_index][1]
                known_patch_filename, _ = os.path.splitext(patch_label)
                
                if ssim_score >= threshold:
                    file.write(f"\t'{known_patch_filename}' with SSIM Score: {ssim_score:.4f}\n")
                else:
                    file.write(f"\tOutlier\n")
            
            file.write("\n")

# image Crop size (width, height) in pixels
crop_size = (900, 750) 

# Patch size (width, height) in pixels
patch_size = (150, 150) 

# input image to analyze
filename = 'landscape_2.jpg'

# input image folder
test_img_path = os.path.join('input_images', filename) 

# known_patches folder
known_patches_dir = 'output_directory/elements'

# Load known patches and store filenames as labels
labels = load_known_patches(known_patches_dir)

# Extract the patches and filenames separately
known_img_patches, known_patch_filenames = zip(*labels)

# Thresholds for Canny edge detection
low_threshold = 50
high_threshold = 200

k = 3 # K nearest neighbors to consider

input_img_patches = crop_and_patch_image(test_img_path, crop_size, patch_size)

input_edge_maps = analyze_edges(input_img_patches, low_threshold, high_threshold)

# Calculate SSIM scores for all patches
all_ssim_scores = calculate_ssim(input_edge_maps, known_img_patches)

# Get the k-NN results from the SSIM scores
knn_results = knn_ssim(all_ssim_scores, k)
threshold =0.55

# Optional: To print the number of patches and check if all patches are the same size
print(f"Number of input patches: {len(input_img_patches)}")
patch_sizes = set(patch.shape[:2] for patch in input_img_patches)
if len(patch_sizes) == 1:
    print(f"All patches are the same size: {patch_sizes.pop()}")
else:
    print("Patches vary in size:")
    for size in patch_sizes:
        print(size)
print()
output_file = "labels.txt"
label_patches(knn_results, labels, threshold, output_file)