% Functions for controlling Arcus DMX-J-SA-17 stage

% MyArcus.DevInfo       get the device informations
% MyArcus.goHome        Return to the home value
% MyArcus.HCA           get/set the Home correction value [Use (0) to know home value]
% MyArcus.IsBusy        is motor "Working = 1" or "Free = 0"
% MyArcus.Abort         Abort the operation
% MyArcus.Stop          Stop the motor
% MyArcus.Enable        Enable the motor fot the operations
% MyArcus.Disable       Disable from receiving the commands
% MyArcus.DevStatus     get the status upon Table 7.0 from datasheet       
% MyArcus.JogPlus       Move to the Positive direction for infinite time
% MyArcus.JogMinus      Move to the Negative direction
% MyArcus.setMoveMode   Set the move mode with 'ABS" = (0) or 'INC' = (1)
% MyArcus.MoveMode      know which mode is ON in the motor
% MyArcus.resetStage    reset perameters to the Constant Values   
% MyArcus.getParams     Get the exact operating perameters from the motor
% MyArcus.setParams     adjust all the parameters as per need e.g.(0,1000,300,300)
% MyArcus.PositionTo    turn the motor ( 0-3200 ) steps
% MyArcus.Current_Pos   Get Motor's current position 
% MyArcus.BackToZero    set the motor position to 0


classdef MyArcus
    properties(Constant) % Constant values set into the motor
        H_vel = 1000; % HSPD High speed setting for stage (pps-pulses per second)
        L_vel = 300; % LSPD Low speed setting for stage (pps)
        Accn = 300; % Accelaration time (ms)
        time_out = 10; % Time out value (ms)
               
    end
    
    methods (Static)
        
        % Device information
        function out = DevInfo()
            out = [];
            out.ID = RunCMD('ID');
            out.Ver = RunCMD('VER');
        end        
        
        % moveHome
        function out = goHome()
           
            RunCMD('CLR')
            RunCMD('EO=1');% enable driver
            RunCMD('DL=0');% enable disable limit
            out = RunCMD('L-');% go to negative limit
            % wait till stage arrives
            
            
            jj = 1;
            while jj > 0
                if MyArcus.IsBusy<1
                    jj = 0;
                end
            end
            RunCMD('CLR');% clear limit error
           
        end
        
        
        % Home correction amount
        function out = HCA(choice)
            if choice == 0              % Home correction amount
                out = RunCMD('HCA');
            else 
                out = RunCMD('HCA=',num2str(choice)); % set the Home correction amout
            end
        end
        
        
        % is stage busy?
        function out = IsBusy()
            out = RunCMD('MST');
            if strcmp(out,'1')
                out = 1;
            else
                out = 0;
            end
        end
        
        % abort
        function out = Abort()
            comm = 'ABORT';
            out = RunCMD(comm);
            RunCMD('CLR')
        end
        
        % stop 
        function out = Stop()
            comm = 'STOP';
            out = RunCMD(comm);
            RunCMD('CLR')
        end
        
        % Enable the motor
        function out = Enable()
            RunCMD('CLR')
            comm = 'EO';
            out = RunCMD(comm);
            if strcmp(out, '0')
               comm = 'EO';
               out = RunCMD(comm,'=1');
               RunCMD('ABORT');
            end
        end
        
        % Disable the motor
        function out = Disable()
            RunCMD('CLR')
            comm = 'EO';
            out = RunCMD(comm);
            if strcmp(out, '1')
               comm = 'EO';
               out = RunCMD(comm,'=0');
            end
        end
        

        
        % Device status
        function out = DevStatus()
            comm = 'MST';
            out = RunCMD(comm);
        end
        
        % Jog plus
        function out = JogPlus()
            RunCMD('CLR');
            comm = 'J+';
            out = RunCMD(comm);
            RunCMD('CLR');
        end
        
        % Jog minus
        function out = JogMinus()
            RunCMD('CLR');
            comm = 'J-';
            out = RunCMD(comm);
            RunCMD('CLR');
        end
        
    
        % set move mode
        function out = setMoveMode(choice)      % set move mode to INC = (1) (incremental) or ABS = (0) (abbsolute)
            out = RunCMD('MM');                 % e.g MyArcus.setMoveMode(0)
            if (choice == 0)&&(out == '1')
                comm = 'ABS';                   % for absolute mode (0)
                out = RunCMD(comm);
            elseif (choice == 1)&&(out == '0')
                comm = 'INC';                   % for incremental mode (1)
                out = RunCMD(comm);
            end
        end

        % Device Move Mode
        function out = MoveMode()
            out = RunCMD('MM');
        end        
        
        % reset the stage to default
        function out = resetStage()
            RunCMD('CLR');
            try
                RunCMD('HSPD',['=',num2str(MyArcus.H_vel)]); 
                RunCMD('LSPD',['=',num2str(MyArcus.L_vel)]);
                RunCMD('ACC',['=',num2str(MyArcus.Accn)]);
                out = RunCMD('TOC',['=',num2str(MyArcus.time_out)]);
            catch
                out = 'check reset function again...';
            end
        end
        
        
        % get parameters (current position, accn and velocity)
        function out = getParams()
            out = [];
            RunCMD('CLR');
            pos = RunCMD('PX');
            l_vel = RunCMD('LSPD');
            h_vel = RunCMD('HSPD');
            accn = RunCMD('ACC');
            
            out.pos = double(pos);
            out.h_vel = double(h_vel);
            out.l_vel = double(l_vel); 
            out.accn = double(accn);
        end
        
        
        % set parameters (position, accn, velocity)
        function out = setParams(pos, h_vel, l_vel, accn)
            out = RunCMD('CLR');
            if strcmp(out, 'OK')
                RunCMD('HSPD',['=',num2str(h_vel)]);
                RunCMD('LSPD',['=',num2str(l_vel)]);
                RunCMD('ACC',['=',num2str(accn)]);
                RunCMD('X',num2str((16000 * pos) / 360));
                out = 'Done';
            end
        end
        
        function out = motor_status()
            
            try
                out = RunCMD('MST');
                if strcmp(out,'1')
                   return 
                else
                    out = 0;
                end
            catch               
            end
        end
        
        % move to the position ( 0-3200 ) ( 0-360' )(16 = 1.8 Degree)
        function out = PositionTo(pos)
            out = RunCMD('CLR');
            out2 = RunCMD('MM');
            if strcmp(out2,'0')&&(pos < 361)
                RunCMD('X',num2str((16000 * pos) / 360));                
            end
        end 
        
        % Get Motor's current position 
        function out = Current_Pos()
            cmd = str2double(RunCMD('PX'));
            out = ((360 * cmd) / 16000);
        end 
        
        % Set current position to zero 
        % motor ni position ne jiro par set karva mate aa use karva no che
        % jya hase tya ne tya j zero set thay jase
        function out = BackToZero()
            comm = 'PX';
            out = RunCMD(comm,'=0');
        end        
    end
    
end
