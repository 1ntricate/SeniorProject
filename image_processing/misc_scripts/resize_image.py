import cv2
import os

# resizes a single image

def crop_and_save_resized_image(image_path, crop_size, output_path):
    # Load the image
    image = cv2.imread(image_path)
    
    # Check if the image is loaded
    if image is None:
        print(f"Error: Failed to load image '{image_path}'")
        return False
    
    # Resize the image to the desired size
    resized_image = cv2.resize(image, (crop_size[0], crop_size[1]))
    
    # Save the resized image to the specified output path
    cv2.imwrite(output_path, resized_image)
    
    return True

# Image crop size (width, height) in pixels
crop_size = (1500, 900) 

# Input image
filename = 'landscape_2.jpg'

# Input image folder
input_img_path = os.path.join('input_images', filename)

# Output path for the resized image
output_img_path = os.path.join('resized_images', 'resized_' + filename)
# Ensure the output directory exists
output_dir = os.path.dirname(output_img_path)
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

success = crop_and_save_resized_image(input_img_path, crop_size, output_img_path)

if success:
    print(f"Resized image saved to '{output_img_path}'")
else:
    print("Failed to resize and save the image.")
