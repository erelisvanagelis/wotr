import cv2
import numpy as np

# This script is not very efficient, the more rgb colors it has, the more it srugless. But it works

# Adjust according to your adjacency requirement.
kernel = np.ones((3, 3), dtype=np.uint8)

img = cv2.imread('map_mask.png') 

all_rgb_codes = img.reshape(-1, img.shape[-1])
unique_rgbs = np.unique(all_rgb_codes, axis=0)
print('Unique Color Count: ', unique_rgbs.size)

masks = []
interator = 0
for color in unique_rgbs:
    color_mask = cv2.inRange(img, color, color)
    masks.append(cv2.dilate(color_mask, kernel, iterations=1))

common_bits = []
interator = 0
for this_mask in masks:
    for other_mask in masks:
        if (this_mask is other_mask):
            continue

        common_bits.append(cv2.bitwise_and(this_mask, other_mask))

total_common = common_bits[0]
interator = 0
for bit in common_bits:
    total_common = cv2.add(total_common, bit)

cv2.imshow('preview', total_common) 
cv2.imwrite("map_black_white.png", total_common) 
cv2.waitKey(0)    