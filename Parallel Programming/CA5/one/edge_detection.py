import cv2
import numpy as np  
import multiprocessing as mp
import matplotlib.pyplot as plt
import time


def single(img):
    rows,cols = img.shape

    kernel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    kernel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])

    grad = np.zeros((rows,cols))
    grad_x = np.zeros((rows,cols))
    grad_y = np.zeros((rows,cols))
    image = np.array(img, dtype = 'double')

    time1 = time.time_ns()
    for i in range(1, rows-1):
        for j in range(1, cols-1):
            s1 = 0
            s2 = 0
            for x in range(3):
                for y in range(3):
                    s1 = s1 + image[i + x - 1][j + y - 1] * kernel_x[x][y]
                    s2 = s2 + image[i + x - 1][j + y - 1] * kernel_y[x][y]
            grad_x[i][j] = s1
            grad_y[i][j] = s2
    grad = np.sqrt(grad_x**2 + grad_y**2 )
    grad = grad / np.max(grad)
    #cv2.imshow('single', grad)
    #cv2.waitKey(0)
    time2 = time.time_ns()

    return (time2 - time1)/10**9

def mul(p):
    image = p[0]
    i = p[1]
    j = p[2]
    kernel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    kernel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])
    s1 = 0
    s2 = 0
    for x in range(3):
        for y in range(3):
            s1 = s1 + image[i + x - 1][j + y - 1] * kernel_x[x][y]
            s2 = s2 + image[i + x - 1][j + y - 1] * kernel_y[x][y]

    return np.sqrt(s1**2 + s2**2)
def parallel(img, p):
    rows,cols = img.shape
    grad_x = np.zeros((rows,cols))
    grad_y = np.zeros((rows,cols))
    image = np.array(img, dtype = 'double')
    inputs = []

    time1 = time.time_ns()
    for i in range(1, rows-1):
        for j in range(1, cols-1):
            inputs.append([image, i, j])
    if __name__ == '__main__':
        pool = mp.Pool(processes = p)
        grad = pool.map(mul, inputs, chunksize=20000)
        grad = np.reshape(grad, (rows-2, cols-2))
        grad = grad / np.max(grad)

        #cv2.imshow('parallel', grad)
        #cv2.waitKey(0)
    time2 = time.time_ns()

    return (time2 - time1)/10**9
img = cv2.imread('flower.jpg', 0)

single_time = single(img)

num_process = []
time_list = []
speedup = []
eff = []

n = 16

for i in range(2, n + 1):
    num_process.append(i)
    time_list.append(parallel(img, i))

for i in range(2, n + 1):
    speedup.append(single_time/ time_list[i - 2])
    eff.append(speedup[i - 2]/i)
print(time_list)
print(speedup)
print(eff)

plt.plot(num_process, time_list, marker='s', linestyle='-', color='r', label="time")
plt.plot(num_process, speedup, marker='o', linestyle='--', color='b', label="speedup")
plt.plot(num_process, eff, marker='s', linestyle=':', color='r', label="Efficiency")

plt.title("Plot")
plt.xlabel("X-axis")
plt.ylabel("Y-axis")

plt.legend()

plt.grid()
plt.show()

#print("single" , single(img))
#print("paralel" ,parallel(img))
