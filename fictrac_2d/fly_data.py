from . import utils
from scipy.stats import circmean
import numpy as np

class FlyData(object):
    """
        Fly location data and stim status

        parameter summary  (param)

          frame                 - frame number on fictrac
          posx                  - x position - *ball radius
          poxy                  - y position
          velx                  - x velocity
          vely                  - y velocity
          intx                  - x pos BALL
          inty                  - y pos BALL (over 2pi)
          heading               - heading (in deg) FICTRAC
          finalheading          - heading (WITH BAR JUMPS)

        """

    def __init__(self):
        self.time_window = 300

        self.count = 0
        self.time_list = []
        self.panel_heading_list = []
        self.goal_heading = 0
        self.time = 0
        self.heading = 0
        self.intx = 0
        self.inty = 0
        self.velx = 0
        self.vely = 0
        self.posx = 0
        self.posy = 0
        self.velheading = 0
        self.panel_heading = 0
        self.panel_x = 0
        self.frame = 0
        #I'm adding the definition of an accum x
        self.accumx = 0

        self.reset() # Initialize member data

    def add(self, t, data):
        # Add new data points
        self.time = t
        self.heading = data['heading']
        self.intx = data['intx']
        self.inty = data['inty']
        self.velx = data['velx']
        self.vely = data['vely']
        self.posx = data['posx']
        self.posy = data['posy']
        self.velheading = data['deltaheading']
        self.frame = data['frame']
        #I'm adding a delta x to make it easier to specify a walked distance, MB 20190805
        self.accumx += self.velx

    def update_panel_heading(self, t, panel_jump, gain_yaw, open_loop, open_loop_value):
        if open_loop == 1:
            self.panel_heading = open_loop_value
        else: #if it is closed-loop
            self.panel_heading = (self.panel_heading + self.velheading*gain_yaw + panel_jump) % 360
            #make the panel yaw be the previously stored panel yaw value + the change in heading of the animal by the yaw gain, plus the panel jump value

        self.time_list.append(self.time)
        self.panel_heading_list.append(self.panel_heading)
        if self.count >= 2:
            self.goal_heading = 360*circmean([x*2*np.pi/360 for x in self.panel_heading_list])/2/np.pi
        self.count += 1

        # Cull old data points
        while (t - self.time_list[0]) > self.time_window:
            self.time_list.pop(0)
            self.panel_heading_list.pop(0)

    def update_panel_x(self, gain_x, open_loop, open_loop_value):
        if open_loop == 1:
            self.panel_x = open_loop_value
        else:
            self.panel_x = (self.panel_x + self.velx*gain_x*360/2/np.pi) % 360

    def reset(self):
        self.count = 0
        self.time_list = []
        self.panel_heading_list = []
        self.goal_heading = 0
        self.time = 0
        self.heading = 0
        self.intx = 0
        self.inty = 0
        self.velx = 0
        self.vely = 0
        self.posx = 0
        self.posy = 0
        self.velheading = 0
        self.panel_heading = 0
        self.panel_x = 0
        self.frame = 0
        #I'm adding the reset for an accumx - MB 20190805
        self.accumx = 0