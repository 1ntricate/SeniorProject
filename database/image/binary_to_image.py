import base64
import os

# Path to the folder where the binary data files are stored
binary_folder = "./binary_image_data"
# Path to the folder where you want to save the image files
image_folder = "./converted_images"

# Create the 'recovered_images' folder if it doesn't exist
os.makedirs(image_folder, exist_ok=True)

# List all binary files in the 'binary_folder'
binary_files = [f for f in os.listdir(binary_folder) if f.endswith(".bin")]

for binary_filename in binary_files:
    # Construct the full path to the binary file
    binary_path = os.path.join(binary_folder, binary_filename)

    # Read the binary data from the binary file
    with open(binary_path, "rb") as binary_file:
        base64_data = binary_file.read()

    # Decode the base64 data to obtain the binary image data
    binary_data = base64.b64decode(base64_data)

    # Specify the filename and path for the image file
    image_filename = os.path.splitext(binary_filename)[0]  # Remove the ".bin" extension
    image_path = os.path.join(image_folder, image_filename)

    # Write the binary data as an image file
    with open(image_path, "wb") as image_file:
        image_file.write(binary_data)

print("Binary files have been successfully converted to images.")
