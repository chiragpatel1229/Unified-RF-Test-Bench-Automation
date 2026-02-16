
Delay = 0.010;
fprintf("Communication Time Calculation Between EXA and MXG.\n  With %d second time pause. \n \n",Delay);
h = 0;  
tic;
while h<25
    if h == 5
        obj1.SetPowerLevel(10);               
        fprintf("\n \n set power = 10\n");
        toc 
        fprintf("\n \n");
    elseif h == 10
        obj1.SetPowerLevel(5);                
        fprintf("\n \n set power = 5\n");
        toc 
        fprintf("\n \n");
    elseif h == 15
        obj1.SetPowerLevel(0);                
        fprintf("\n \n set power = 0\n");
        toc 
        fprintf("\n \n");
    elseif h == 20
        obj1.SetPowerLevel(15);
        fprintf("\n \n set power = 15\n");  
        toc 
        fprintf("\n \n");
    end
    pause (Delay)
    P = obj.Get_Marker_Power(1);
    fprintf(P);
    toc
    h = h+1;
end