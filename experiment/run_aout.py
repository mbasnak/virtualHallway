import os
import sys
sys.path.insert(0, os.path.abspath('C:/Users/wilson_lab/Desktop/MelanieFictrac/conditioned_menotaxis-master'))
from fictrac_2d import FicTracAout

if __name__ == '__main__':
    client1 = FicTracAout()
    client1.run(1)



