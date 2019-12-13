
function stopF(src, event)
 
%with the end of the hallway in dimension 12
     %if  (mode(event.Data(:,6)) > 1.26 && mode(event.Data(:,6)) < 7.5)
         
%with the end of the hallway in dimension 24

     if  (mode(event.Data(:,6)) > 2.56 && mode(event.Data(:,6)) < 7.5)    
         

       if isnan(src.UserData.time)
           src.UserData.time = clock;
           
       elseif (sum(clock-src.UserData.time) > 0.5 && sum(clock-src.UserData.time) < 1.0)
           Panel_com('stop');
           Panel_com('all_off');            
           
       elseif sum(clock-src.UserData.time) > 1.0          

           src.stop()
           outputSingleScan(src,[0 0 1])

       end
       
    end

    
end