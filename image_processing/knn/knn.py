import cv2
import os
import numpy as np
import csv
import pandas as pd
from skimage.feature.texture import graycomatrix, graycoprops

# splits input image into patches then extracts the average color and edge count of each patch
# these features are used as inputs for a KNN classication

# Load known data from CSV file
def load_csv(csv_file):
    known_data = []
    with open(csv_file, mode='r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            # Extract the features (B, G, R, Edge Count), label, and type from each row
            features = [float(row[0]), float(row[1]), float(row[2]), float(row[3]),float(row[4]), float(row[5]), float(row[6]),float(row[7])]
            label = row[8]
            type = row[9]
            known_data.append((features, label,type))
    return known_data

def resize_image(image_path, re_size):
    # Load the image
    image = cv2.imread(image_path)
    
    # Check if the image is loaded
    if image is None:
        print(f"Error: Failed to load image '{image_path}'")
        return None
    
    # Resize the image to the desired size
    resized_image = cv2.resize(image, (re_size[0], re_size[1]))
    
    return resized_image

# split image into patches
def patch_image(image, patch_width, patch_height):
    patches = []
    height, width, _ = image.shape

    for y in range(0, height, patch_height):
        for x in range(0, width, patch_width):
            patch = image[y:y+patch_height, x:x+patch_width]
            patches.append(patch)

    return patches

# Calculate the average patch color
def avg_patch_color(patch):
    average_color = np.mean(patch, axis=(0, 1))
    return average_color.astype(int)

# Count edges in patch
def patch_edges(patch, low_threshold, high_threshold):
    if patch.ndim == 3 and patch.shape[2] == 3:
        # Convert patch to grayscale
        gray_patch = cv2.cvtColor(patch, cv2.COLOR_BGR2GRAY)
    else:
        # If the image is already one channel, assume it is grayscale
        gray_patch = patch
    # Detect edges in the patch
    edges = cv2.Canny(gray_patch, low_threshold, high_threshold)
    
    # Count the number of edge pixels
    edge_count = cv2.countNonZero(edges)
    
    return edge_count

# calculate how similar the input patch is to elements (using 4 features)
def euclidean_distance(input_vector, element_vector):
    input_vector = np.array(input_vector, dtype='float64')  
    element_vector = np.array(element_vector, dtype='float64')  
    
    # Print the input vectors
    #print(f"Input vector: {input_vector}")
    #print(f"Element vector: {element_vector}")
    
    # Calculate the Euclidean distance
    distance = np.sqrt(np.sum((input_vector - element_vector) ** 2))
    #print(f"Euclidean distance: {distance}")
    
    return distance

# predict lables & types
def Knn(input_vector, known_data, k, threshold):
    distances_and_labels = []
    for i, feature_vector in enumerate(known_data):
        # pass the current input patch info
        norm_vec = feature_vector[0]
        label = feature_vector[1]
        type = feature_vector[2]
        distance = euclidean_distance(input_vector[0],norm_vec )
        distances_and_labels.append((distance, label, type))

    # Sort the list in ascending order of distances
    sorted_distances_and_labels = sorted(distances_and_labels, key=lambda x: x[0])
    class_counts = {}
    type_counts = {}
    labels_types =[]
    types = []
    # iterate through k nearest neighbors, predict labels
    for i in range(k):
        
        type = sorted_distances_and_labels[i][2] 
        label = sorted_distances_and_labels[i][1] 
        d_d = sorted_distances_and_labels[i][0]  
        if d_d <= threshold:
            print(f"{i+1} distance: {d_d} label: {label}, type: {type}")
            labels_types.append((label,type))
            types.append(type)
        else:
            # outlier
            print(f"{i+1} No elements within distance threshold")
    for type in types:
        if type in type_counts:
            type_counts[type] += 1
        else:
            type_counts[type] = 1
    
    #smallest_distance_label = sorted_distances_and_labels[0][1]
    #most_common_type = max(type_counts, key=type_counts.get)
    if not sorted_distances_and_labels:
        smallest_distance_label = 'Outlier'
    else:
        smallest_distance_label = sorted_distances_and_labels[0][1]

    if not type_counts:
        most_common_type = 'Outlier'
    else:
        most_common_type = max(type_counts, key=type_counts.get)
    

    return smallest_distance_label, most_common_type

def compute_texture_features(patch):
    # Convert the patch to grayscale
    gray = cv2.cvtColor(patch, cv2.COLOR_BGR2GRAY)
    
    # Compute the GLCM matrix
    glcm = graycomatrix(gray, distances=[1], angles=[0], levels=256, symmetric=True, normed=True)
    
    # Compute GLCM properties
    contrast = graycoprops(glcm, prop='contrast')[0, 0]
    dissimilarity = graycoprops(glcm, prop='dissimilarity')[0, 0]
    homogeneity = graycoprops(glcm, prop='homogeneity')[0, 0]
    energy = graycoprops(glcm, prop='energy')[0, 0]
    
    return contrast, dissimilarity, homogeneity, energy


def get_patch_info(patch_info_array):
    feature_vectors = []
    # Loop through the patch_info_array
    for patch_data in patch_info_array:
        patch_num = patch_data['patch_num']
        average_color_BGR = patch_data['average_color_BGR']
        edge_count = patch_data['edge_count']

        # Create a feature vector with B, G, R, and edge count
        feature_vector = [average_color_BGR[0], average_color_BGR[1], average_color_BGR[2], edge_count]
    
        # Combine image name and patch number as the label and add it to the feature vector
        label = f"{input_img_name}_{patch_num}"
        feature_vector.append(label)
    
        # Append the feature vector to the feature_vectors list
        feature_vectors.append(feature_vector)

    return feature_vectors

def add_text_to_patches(resized_image, label,type, patch_num):
    border_color = (0, 255, 0) 
    # Add label text to the patch
    text = f"{patch_num}: {type}, {label}"
    text_position = (10, 30) 
    cv2.putText(patch_2, text, text_position, cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
    # Calculate the x and y coordinates to place the patch in the result image
    x = (patch_num - 1) % (resized_image.shape[1] // patch_size[0]) * patch_size[0]
    y = (patch_num - 1) // (resized_image.shape[1] // patch_size[0]) * patch_size[1]
    # add patch borders
    border_thickness = 2
    cv2.rectangle(
        result_image,
        (x, y),
        (x + patch_size[0], y + patch_size[1]),
        border_color,
        border_thickness
    )
    # Place the labeled patch onto the result image
    result_image[y:y+patch_size[1], x:x+patch_size[0]] = patch_2
   
# Resize image (width, height) in pixels
re_size = (1500, 900) 
# Patch size (width, height) in pixels
patch_size = (300, 300)

# canny edge detection thresholds
low_threshold = 50 
high_threshold = 150  

# Read the CSV file
csv_file= 'known_data.csv'
known_data = load_csv(csv_file)

# weights for features
# [B, G, R, Edge Count, Contrast, Dissimilarity, Homogeneity, Energy]
weights = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]  

patch_info = []
patches = []

# k nearest neghbors to consider
k = 5
# distance threshold for knn
threshold = 2.2
# Begin

# load input image (image to identify)
filename = '6_landscape.jpg'
print(f"Input image: {filename}\n")

# Input image folder
input_img_path = os.path.join('input_images', filename)

# resize the image
resized_image = resize_image(input_img_path, re_size)
result_image = resized_image.copy()

# loop throuogh all patches
if resized_image is not None:
    print("Image resized successfully.")
    # Split the resized image into patches
    patches = patch_image(resized_image, patch_size[0], patch_size[1])
    print("Image patched successfully.\n")
    for i, patch in enumerate(patches):
        average_color = avg_patch_color(patch)
        edges = patch_edges(patch, low_threshold, high_threshold)
        contrast, dissimilarity, homogeneity, energy = compute_texture_features(patch)
        # dictionary to store information about the patch
        patch_data = {
            'patch_num': i + 1,
            'average_color_BGR': average_color,
            'edge_count': edges,
            'contrast':contrast,
            'dissimilarity': dissimilarity,
            'homogeneity': homogeneity,
            'energy': energy,
        }
        patch_info.append(patch_data)
    # Convert the list of patch information dictionaries into a NumPy array
    patch_info_array = np.array(patch_info)
else:
    print("Failed to resize the image.")

feature_vectors = []
input_img_name = filename.split('.')[0] 

# Loop through the patch_info_array
for patch_data in patch_info_array:
    patch_num = patch_data['patch_num']
    average_color_BGR = patch_data['average_color_BGR']
    edge_count = patch_data['edge_count']
    contrast = patch_data['contrast']
    dissimilarity = patch_data['dissimilarity']
    homogeneity = patch_data['homogeneity']
    energy = patch_data['energy']   
    # Create a feature vector with B, G, R, and edge count
    feature_vector = [average_color_BGR[0], average_color_BGR[1], average_color_BGR[2], edge_count,contrast,dissimilarity, homogeneity,energy]
    
    # Combine image name and patch number as the label and add it to the feature vector
    label = f"{input_img_name}_{patch_num}"
    feature_vector.append(label)
    
    # Append the patch vector to the feature_vectors list
    feature_vectors.append(feature_vector)

# Extract all values of each feature vector in both datasets (numerical values)
feature_vectors_values = [feature_vector[:8] for feature_vector in feature_vectors]  # Exclude the label
known_data_values = [data[0] for data in known_data]

# Combine both datasets
combined_values = feature_vectors_values + known_data_values

print(f"feature vector values len:{len(feature_vectors_values[0])}")
print(f"known data len:{len(known_data_values[0])}")

# Calculate mean and standard deviation separately for each feature
mean = np.mean(combined_values, axis=0)
std_dev = np.std(combined_values, axis=0)


normalized_feature_vectors = [
    [(feature_value * weight - feature_mean) / feature_std_dev
     for feature_value, weight, feature_mean, feature_std_dev in zip(feature_vector, weights, mean, std_dev)]
    for feature_vector in feature_vectors_values
]

normalized_known_data = [
    [(data_value * weight - data_mean) / data_std_dev
     for data_value, weight, data_mean, data_std_dev in zip(data, weights, mean, std_dev)]
    for data in known_data_values
]

# Re-add labels to the normalized lists
normalized_input_features = [(normalized_feature_vector, feature_vector[8]) for normalized_feature_vector, feature_vector in zip(normalized_feature_vectors, feature_vectors)]
normalized_known_features = [(normalized_data, data[1], data[2]) for normalized_data, data in zip(normalized_known_data, known_data)]

# Knn classification
for i, feature_vector in enumerate(normalized_input_features):
    # pass the current input patch info
    label,type = Knn(feature_vector,normalized_known_features,k,threshold)
    
    patch = feature_vector[1]
    patch_2 = patches[i]
    patch_num = i + 1
    print(f"{patch} is classified as type: {type}, element: {label}")
    print("----------------------------------------------------------------\n")
    add_text_to_patches(result_image, label,type, patch_num)

print("Press q to close displayed image")
# Display the result image with labeled patches and borders
cv2.imshow("Result Image with Labeled Patches", result_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
