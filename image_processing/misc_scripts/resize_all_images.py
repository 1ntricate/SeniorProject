import cv2
import os

# resizes all the images inside the input_images folder

def crop_and_save_resized_image(image_path, crop_size, output_path):
    # Load the image
    image = cv2.imread(image_path)
    
    # Check if the image is loaded
    if image is None:
        print(f"Error: Failed to load image '{image_path}'")
        return False
    
    # Get the dimensions of the loaded image
    height, width, _ = image.shape
    
    # Check if the image is at least 1500x900 in size
    if width < crop_size[0] or height < crop_size[1]:
        print(f"Error: Image '{image_path}' is too small to resize to {crop_size[0]}x{crop_size[1]}")
        return False
    
    # Resize the image to the desired size
    resized_image = cv2.resize(image, (crop_size[0], crop_size[1]))
    
    # Get the file extension from the input image path
    _, extension = os.path.splitext(image_path)
    
    # Ensure that the output path has a valid image file extension
    valid_extensions = ['.jpg', '.jpeg', '.png', '.bmp']
    if extension.lower() not in valid_extensions:
        print(f"Error: Unsupported file format '{extension}' for '{image_path}'")
        return False
    
    # Append a valid image file extension to the output path
    output_path += extension
    
    # Save the resized image to the specified output path
    cv2.imwrite(output_path, resized_image)
    
    return True

# Image crop size (width, height) in pixels
crop_size = (300, 300)

# Input image folder
input_dir = 'elements'

# Output directory for the resized images
output_dir = 'resized_elements'

# Ensure the output directory exists
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# List all files in the input directory
input_files = os.listdir(input_dir)

# Process each image in the input directory
for filename in input_files:
    # Input image path
    input_img_path = os.path.join(input_dir, filename)
    
    # Output path for the resized image
    output_img_path = os.path.join(output_dir, 'resized_' + filename)
    
    # Call the function to crop, resize, and save the image
    success = crop_and_save_resized_image(input_img_path, crop_size, output_img_path)
    
    if success:
        print(f"Resized image saved to '{output_img_path}'")
    else:
        print(f"Failed to resize and save the image '{input_img_path}'")
