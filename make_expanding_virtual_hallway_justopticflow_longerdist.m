%Make virtual hallway that is made of translational front to back optic
%flow

clear all; close all
pattern.x_num = 96; % number of pixels in the x axis (there are 8 pixels per panel, and 12 panels)
pattern.y_num = 92; 
pattern.num_panels = 24; % there are 24 panels
pattern.gs_val = 3; % we are setting the grayscale value at 2. This is the intensity
Pats = zeros(16, 96, pattern.x_num, pattern.y_num);


stripe_pattern{1} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{2} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{3} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{4} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{5} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{6} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{7} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{8} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{9} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{10} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{11} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{12} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{13} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{14} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{15} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{16} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{17} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{18} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{19} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{20} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{21} = [ones(16,1),repmat([zeros(16,2),ones(16,2)],1,10)                            ,zeros(16,6)     ,repmat([ones(16,2),zeros(16,2)],1,10),ones(16,2)                                          ,zeros(16,6)     ,ones(16,1)];
stripe_pattern{22} = [ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2),ones(16,1)      ,zeros(16,6)     ,ones(16,1),zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,9),ones(16,2),zeros(16,1)        ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{23} = [zeros(16,1),ones(16,2),repmat([zeros(16,2),ones(16,2)],1,9),zeros(16,2)     ,zeros(16,6)     ,zeros(16,2),repmat([ones(16,2),zeros(16,2)],1,10)                                         ,zeros(16,6)     ,zeros(16,1)];
stripe_pattern{24} = [repmat([zeros(16,2),ones(16,2)],1,10),zeros(16,1)                           ,zeros(16,6)     ,zeros(16,1),repmat([ones(16,2),zeros(16,2)],1,10),ones(16,1)                              ,zeros(16,6)     ,ones(16,1)];


for i = 25:58
    stripe_pattern{i} = stripe_pattern{24};
end

for i = 59:92
    stripe_pattern{i} = stripe_pattern{1};
end

for j = 1:pattern.y_num %for every y dimension
    
    for i = 1:96
        Pats(:,:,i,j) = stripe_pattern{1,j};
    end

end

pattern.Pats = Pats;

pattern.panel_map = [12 8 4 11 7 3 10 6 2 9 5 1;...
                     24 20 16 23 19 15 22 18 14 21 17 13];


pattern.Panel_map = pattern.panel_map;
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

%% Save data

directory_name = 'C:\Users\wilson_lab\Desktop\MelanieFictrac\panels-matlab_071618\Patterns\mel360_36panels';
str = [directory_name '\Pattern045_expanding_vhallway_justopticflow_longer_dist'];
save(str, 'pattern'); % save the file in the specified directory