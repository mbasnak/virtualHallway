import os
import sys
sys.path.insert(0, os.path.abspath('C:/Users/wilson_lab/Desktop/MelanieFictrac/conditioned_menotaxis-master'))
from fictrac_2d import FicTracAoutEmpty

if __name__ == '__main__':
    client1 = FicTracAoutEmpty()
    client1.run(1,0.5)