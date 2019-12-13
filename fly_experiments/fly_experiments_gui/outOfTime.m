%This function stops the panels and the data acquisition when the time
%reaches the trial time from the GUI

function outOfTime(src, event)
  
global s2

if  mean(event.TimeStamps) > mean(src.UserData.TrialTime)
         Panel_com('stop')
         Panel_com('all_off')
         src.stop()
         outputSingleScan(s2,1) %output stop trigger to scanimage
     end
          
end