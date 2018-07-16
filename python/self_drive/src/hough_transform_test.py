#!usr/bin/env python3
import matplotlib.pyplot as plt 
import matplotlib.image as mpimg
import numpy as np
import cv2

image = mpimg.imread('exit-ramp.jpg')
gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)

kernel_size = 5
blur_gray = cv2.GaussianBlur(gray, (kernel_size, kernel_size), 0)

low_threashold = 50
high_threshold = 150
masked_edges = cv2.Canny(blur_gray, low_threashold, high_threshold)

rho = 1
theta = np.pi/180
threshold = 1
min_line_length = 10
max_line_gap = 1
line_image = np.copy(image) * 0

lines =cv2.HoughLinesP(masked_edges, rho, theta, threshold, np.array([]),
                            min_line_length, max_line_gap)

for line in lines:
    for x1, y1, x2, y2 in line:
        cv2.line(line_image, (x1,y1), (x2,y2), (255, 0, 0), 10)



color_edges = np.dstack((masked_edges, masked_edges, masked_edges))


combo = cv2.addWeighted(color_edges, 0.8, line_image, 1, 0)
plt.imshow(combo)
plt.show()

np.array()