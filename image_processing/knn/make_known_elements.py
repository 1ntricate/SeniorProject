import cv2
import os
import numpy as np
import csv
from skimage.feature.texture import graycomatrix, graycoprops


# resizes images in the elements folder to patch size 300x300 and extracts the 
# following features of each element: Average color in Blue, Green, Red, and the total number of edges.
# Features are written to known_data.csv and is used by knn.py to label patches from the input image

# to add aditional elements, add images to the elemnts folder, if you want to add
# a new type of element (e.g. dog) create a folder name dog and put dog images in the folder.
# then run this script followd by knn.py

# load and resize images in the elemnts folder
def load_elements(folder_path, target_size=(150, 150)):
    images = []  # List to store loaded and resized images
    image_names = []  # List to store image names
    
    # Iterate through all files in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        
        # Check if the file is an image (you can customize the image extensions)
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
            image = cv2.imread(file_path)
            if image is not None:
                # Resize the image to the target size
                resized_image = cv2.resize(image, target_size)
                images.append(resized_image)
                image_names.append(filename)  # Store the image name
    
    return images, image_names  # Return both resized images and image names

'''
# load all elements in the folder
def load_elements(folder_path):
    images = []  # List to store loaded images
    image_names = []  # List to store image names
    
    # Iterate through all files in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        
        # Check if the file is an image (you can customize the image extensions)
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')):
            image = cv2.imread(file_path)
            if image is not None:
                images.append(image)
                image_names.append(filename)  # Store the image name
    
    return images, image_names  # Return both images and image names
'''

# Calculate the average color of element
def avg_element_color(element):
    average_color = np.mean(element, axis=(0, 1))
    return average_color.astype(int)

# Count edges in element
def element_edges(element, low_threshold, high_threshold):
    if element.ndim == 3 and element.shape[2] == 3:
        # Convert element to grayscale
        gray_element = cv2.cvtColor(element, cv2.COLOR_BGR2GRAY)
    else:
        # If the image is already one channel, assume it is grayscale
        gray_element = element
    # Detect edges in the element
    edges = cv2.Canny(gray_element, low_threshold, high_threshold)
    
    # Count the number of edge pixels
    edge_count = cv2.countNonZero(edges)
    
    return edge_count

def compute_texture_features(element):
    # Convert the element to grayscale
    gray = cv2.cvtColor(element, cv2.COLOR_BGR2GRAY)
    
    # Compute the GLCM matrix
    glcm = graycomatrix(gray, distances=[1], angles=[0], levels=256, symmetric=True, normed=True)
    
    # Compute GLCM properties
    contrast = graycoprops(glcm, prop='contrast')[0, 0]
    dissimilarity = graycoprops(glcm, prop='dissimilarity')[0, 0]
    homogeneity = graycoprops(glcm, prop='homogeneity')[0, 0]
    energy = graycoprops(glcm, prop='energy')[0, 0]
    '''
    print("contrast: ", contrast)
    print("dissimilarity: ", dissimilarity)
    print("homogeneity", homogeneity)
    print("energy: ", energy)
    print("correlation",correlation)
    print("\n")
    '''
    return contrast, dissimilarity, homogeneity, energy

# Create a list to store information about each element
element_info = []
# canny edge detection thresholds
low_threshold = 50 
high_threshold = 150  
# known elements folder
folder_path = 'elements'
# Get a list of subfolders (each folder represents a type)
subfolders = [f.path for f in os.scandir(folder_path) if f.is_dir()]
for type_folder in subfolders:
    type_label = os.path.basename(type_folder)  # Get the folder name as the type_label
    loaded_images, image_names = load_elements(type_folder)

    # iterate through all elements
    if loaded_images is not None:
        print("Images loaded successfully.\n")
        for i, (element, image_name) in enumerate(zip(loaded_images, image_names)):
            average_color = avg_element_color(element)
            edges = element_edges(element, low_threshold, high_threshold)
            contrast, dissimilarity, homogeneity, energy = compute_texture_features(element)
            # store information about the element
            element_data = {
                'element_num': i + 1,
                'average_color_BGR': average_color,
                'edge_count': edges,
                'contrast': contrast,
                'dissimilarity': dissimilarity,
                'homogeneity': homogeneity,
                'energy': energy,
                'image_name': image_name,  # Add the image name to the dictionary
                'type_label': type_label,
            }
            element_info.append(element_data)
    
        # Convert the list of element information dictionaries into a NumPy array
        element_info_array = np.array(element_info)
    else:
        print("Failed to resize the image.")

feature_vectors = []

# Loop through the element_info_array
for element_data in element_info_array:
    average_color_BGR = element_data['average_color_BGR']
    edge_count = element_data['edge_count']
    img_name = element_data['image_name']
    #img_name = img_name.split('.')[0]
    type_label = element_data['type_label']
    #print(type_label)
    contrast = element_data['contrast']
    dissimilarity = element_data['dissimilarity']
    homogeneity = element_data['homogeneity']
    energy = element_data['energy']        
    # Create a feature vector with B, G, R, and edge count
    feature_vector = [average_color_BGR[0], average_color_BGR[1], average_color_BGR[2], edge_count,contrast,dissimilarity, homogeneity,energy,img_name, type_label]
    
    # Append the feature vector to the feature_vectors list
    feature_vectors.append(feature_vector)

# print feature vector
for fv in feature_vectors:
    print(fv)

#output data
csv_file = 'known_data.csv'

# column names
#header = ["Blue", "Green", "Red", "Edge Count", "Label", "Type"]
header = ["Blue", "Green", "Red", "Edge Count", "Contrast", "Dissimilarity", "Homogeneity", "Energy", "Label", "Type"]
# Write the data to a CSV file
with open(csv_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    
    # Write the header row
    writer.writerow(header)
    
    # Write each row of the normalized_feature_vectors
    for fv in feature_vectors:
        writer.writerow(fv)
    
print(f"\nFeature vectors saved to {csv_file}")