import cv2
import os

# splits every image in the input_images folder into patches
# since there is no preprocessing, forcing a specific input image size the
# patches are not all the same size

# Input and output directory paths
input_directory = 'input_images'
output_directory = 'output_patches'

# Create the output directory if it doesn't exist
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Patch (width, height) in pixels
patch_size = (150, 150)

# Iterate through all image files in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(".jpg"):
        # Load the image from the input_images folder
        image_path = os.path.join(input_directory, filename)
        image = cv2.imread(image_path)

        # Extract the image name without the file extension
        image_name = os.path.splitext(filename)[0]

        # Create a folder for the current image
        image_folder = os.path.join(output_directory, image_name)
        if not os.path.exists(image_folder):
            os.makedirs(image_folder)

        # Counter to number the patches sequentially
        patch_counter = 1

        # Extract patches from the image
        for y in range(0, image.shape[0], patch_size[1]):
            for x in range(0, image.shape[1], patch_size[0]):
                patch = image[y:y+patch_size[1], x:x+patch_size[0]]
                patch_filename = os.path.join(image_folder, f'patch_{patch_counter}.jpg')
                cv2.imwrite(patch_filename, patch)
                patch_counter += 1

