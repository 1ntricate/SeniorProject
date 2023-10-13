import base64
import os

# Path to folders 
image_folder = "./images"
binary_folder = "./binary_image_data/"

# Create the 'binary_image_data' folder if it doesn't exist
os.makedirs(binary_folder, exist_ok=True)

# List all files in the 'image_folder'
image_files = os.listdir(image_folder)

for image_filename in image_files:
    # Construct the full path to the image file
    image_path = os.path.join(image_folder, image_filename)

    # Open the image file for reading in binary mode
    with open(image_path, "rb") as image_file:
        # Read the binary data of the image file
        binary_data = image_file.read()
    
    # Encode the binary data as base64
    base64_data = base64.b64encode(binary_data)

    # Specify the filename and path for the binary data file
    output_filename = os.path.join(binary_folder, image_filename + ".bin")

    # Open the binary data file for writing in binary mode
    with open(output_filename, "wb") as binary_file:
        binary_file.write(base64_data)

print("Image files have been successfully converted to bin files.")