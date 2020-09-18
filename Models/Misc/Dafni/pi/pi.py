import math,os,random

K = int(os.environ['STEPS'])
B = int(os.environ['SAMPLES'])

for k in range(K):
    N=0
    for i in range(B):
        x = random.uniform(0,1)
        y = random.uniform(0,1)
        if math.sqrt(x*x + y*y)<1: N = N+1
    estimate = 4*N/B
    print(estimate)

    f = open('/data/outputs/estimate.csv','a')
    f.write(str(estimate)+"\n")
    f.close()
