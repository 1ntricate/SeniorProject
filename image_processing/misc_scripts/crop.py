import cv2
import os
import numpy as np
from skimage.metrics import structural_similarity as ssim


''''
Crops and patches an input image into edge maps

# Cropping is done so we always have the same number and size of patches

# Grayscaling images simplifies the processing because edges in an image
  are characterized by a change in intensity, color is relevant

# Canny edge detection is used to convert greyscaled images into edge maps

'''
# crops and patches an input image into edge maps, which will be used as our
# "elements" aka known data (labels)

# Global variables
top_left_corner = (0, 0)  # Initial top left corner of the crop grid
dragging = False  # A flag to indicate whether the grid is being dragged

crop_coordinates_dict = {}

def click_and_drag(event, x, y, flags, param):
    global top_left_corner, dragging, crop_size, patch_size, image, clone

    # When the left mouse button is pressed, record the starting (x, y) coordinates
    if event == cv2.EVENT_LBUTTONDOWN:
        dragging = True
        top_left_corner = (x, y)

    # When the left mouse button is released, stop dragging
    elif event == cv2.EVENT_LBUTTONUP:
        dragging = False

    # If the mouse is moving and a button is being pressed, draw the grid
    elif event == cv2.EVENT_MOUSEMOVE and dragging:
        # Update the image with the grid
        image = clone.copy()
        draw_grid(image, (x, y), crop_size, patch_size)

def draw_grid(img, top_left, crop_sz, patch_sz):
    start_x, start_y = top_left
    end_x = start_x + crop_sz[0]
    end_y = start_y + crop_sz[1]

    # Draw outer crop area
    cv2.rectangle(img, (start_x, start_y), (end_x, end_y), (255, 255, 255), 2)
    # Draw inner patch rectangles
    for y in range(start_y, end_y, patch_sz[1]):
        for x in range(start_x, end_x, patch_sz[0]):
            cv2.rectangle(img, (x, y), (x + patch_sz[0], y + patch_sz[1]), (255, 255, 255), 1)


def save_crop_coordinates(top_left, crop_sz):
    global crop_coordinates_dict
    crop_coordinates_dict["top_left"] = top_left
    crop_coordinates_dict["crop_size"] = crop_sz

def load_crop_coordinates():
    """Load the crop coordinates from the dictionary."""
    global crop_coordinates_dict
    top_left = crop_coordinates_dict.get("top_left", (0, 0))
    crop_sz = crop_coordinates_dict.get("crop_size", (0, 0))
    return top_left, crop_sz

def visualize_crops_and_patches(image_path, crop_size):
    global image, clone, top_left_corner

    # Load the image and clone it
    image = cv2.imread(image_path)
    clone = image.copy()
    cv2.namedWindow("image")
    cv2.setMouseCallback("image", click_and_drag)

    # Keep looping until the 'q' key is pressed
    while True:
        # Display the image and wait for a keypress
        cv2.imshow("image", image)
        key = cv2.waitKey(1) & 0xFF

        # If the 'q' key is pressed, break from the loop
        if key == ord("q"):
            break
        # If the 'c' key is pressed, save the location of the crop
        if key == ord("c"):
            save_crop_coordinates(top_left_corner, crop_size)
            print(f"Crop coordinates saved: {top_left_corner}")

    # Close all open windows
    cv2.destroyAllWindows()
    return top_left_corner, crop_size


def crop_and_patch_and_map_edges(image_path, output_directory, crop_size, patch_size, low_threshold, high_threshold):
    if not image_path.endswith(".jpg"):
        print(f"The file {image_path} is not a JPG image.")
        return
    
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: Failed to load image '{image_path}'.")
        return
    
    x, y = top_left_corner
    cropped_image = image[y:y + crop_size[1], x:x + crop_size[0]]
    image_name = os.path.splitext(os.path.basename(image_path))[0]
    edge_folder = os.path.join(output_directory, f"{image_name}_edges")

    if not os.path.exists(edge_folder):
        os.makedirs(edge_folder)

    patch_counter = 1

    for y in range(0, crop_size[1], patch_size[1]):
        for x in range(0, crop_size[0], patch_size[0]):
            patch = cropped_image[y:y + patch_size[1], x:x + patch_size[0]]
            gray_patch = cv2.cvtColor(patch, cv2.COLOR_BGR2GRAY)
            edges = cv2.Canny(gray_patch, low_threshold, high_threshold)
            edge_filename = os.path.join(edge_folder, f'{image_name}_{patch_counter}.jpg')
            cv2.imwrite(edge_filename, edges)
            patch_counter += 1


# Example usage:
image_path = 'resized_images/resized_landscape_2.jpg'
output_directory = 'output_directory' 
crop_size = (1500, 900)  # Ensuring the crop size is a multiple of patch size (150x150)
patch_size = (300, 300)

low_threshold = 50  # Canny edge detection low threshold
high_threshold = 150 

# Run the visualization to get the crop area
crop_coordinates, crop_size = visualize_crops_and_patches(image_path, crop_size)
# Now we read the saved crop coordinates and use them
top_left_corner, _ = load_crop_coordinates()

# Finally, call the crop_and_patch_and_map_edges function with the loaded coordinates
crop_and_patch_and_map_edges(image_path, output_directory, crop_size, patch_size, low_threshold, high_threshold)