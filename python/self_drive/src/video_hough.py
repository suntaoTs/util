import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import cv2

import os
import stat

 
origin_path = '/home/suntao/work/CarND-Term1-Starter-Kit-Test/picture/origin/'
transform_path = '/home/suntao/work/CarND-Term1-Starter-Kit-Test/picture/transform/'



def transImage(filename):
    
    # Read in and grayscale the image
    plt_img = mpimg.imread(origin_path+filename)
    image = np.copy(plt_img)

    ysize = image.shape[0]
    xsize = image.shape[1]
    #print('xsize: ', xsize, 'ysize: ', ysize)

    gray = cv2.cvtColor(image,cv2.COLOR_RGB2GRAY)

    # Define a kernel size and apply Gaussian smoothing
    kernel_size =5
    blur_gray = cv2.GaussianBlur(gray,(kernel_size, kernel_size),0)

    # Define our parameters for Canny and apply
    low_threshold = 50
    high_threshold = 150
    edges = cv2.Canny(blur_gray, low_threshold, high_threshold)

    # Next we'll create a masked edges image using cv2.fillPoly()
    mask = np.zeros_like(edges)   
    ignore_mask_color = 255   

    # This time we are defining a four sided polygon to mask
    imshape = image.shape
    vertices = np.array([[(1/7 * xsize, ysize - 55),(1/2 * xsize -60 , 3/5 * ysize), (1/2 * xsize + 60, 3/5 * ysize), (6/7 * xsize, ysize-55)]], dtype=np.int32)
    cv2.fillPoly(mask, vertices, ignore_mask_color)
    masked_edges = cv2.bitwise_and(edges, mask)

    # Define the Hough transform parameters
    # Make a blank the same size as our image to draw on
    rho = 1 # distance resolution in pixels of the Hough grid
    theta = np.pi/180 # angular resolution in radians of the Hough grid
    threshold = 20     # minimum number of votes (intersections in Hough grid cell)
    min_line_length = 20 #minimum number of pixels making up a line
    max_line_gap = 50    # maximum gap in pixels between connectable line segments
    line_image = np.copy(image)*0 # creating a blank to draw lines on

    # Run Hough on edge detected image
    # Output "lines" is an array containing endpoints of detected line segments
    lines = cv2.HoughLinesP(masked_edges, rho, theta, threshold, np.array([]),
                                min_line_length, max_line_gap)

    # Iterate over the output "lines" and draw lines on a blank image
    for line in lines:
        for x1,y1,x2,y2 in line:
            cv2.line(line_image,(x1,y1),(x2,y2),(255,0,0),5)

    # Create a "color" binary image to combine with line image
    color_edges = np.dstack((edges, edges, edges)) 
    plt.imshow(color_edges)

    # 增加边选框
    x = [(1/7 * xsize),(1/2 * xsize -60 ), (1/2 * xsize + 60), (6/7 * xsize)]
    y = [(ysize - 55),( 3/5 * ysize), ( 3/5 * ysize), (ysize-55)]
    plt.plot(x, y, 'b--', lw=2)
    

    # Draw the lines on the edge image
    #lines_edges = cv2.addWeighted(color_edges, 0.8, line_image, 1, 0) 
    lines_edges = cv2.addWeighted(image, 0.8, line_image, 1, 0) 
    #image[np.array(lines_edges)] = [255,0,0]
    plt.imshow(lines_edges)

    #filename = transform_path + 'png/' + filename[:filename.find('.jpg')] + '.png'
    filename = transform_path + 'jpg/' + filename
    #plt.show()
    #mpimg.imsave('my_test.jpg', lines_edges)
    #cv2.imwrite(r'my_test.jpg', lines_edges[...,-1::-1])
    cv2.imwrite(filename, lines_edges[...,-1::-1])

def main():
    files = os.listdir(origin_path)

    for file in files:
        #if stat.S_ISREG(stat(file, dir_fd=topfd).st_mode):
        #print(file)
        transImage(file)


if __name__ == '__main__':
    main()


    


