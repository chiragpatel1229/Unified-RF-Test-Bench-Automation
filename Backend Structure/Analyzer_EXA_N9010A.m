%  Instructions for use, for the Agilent N9010A spectrum analyzer control


%  obj = Analyzer_EXA_N9010A()          Connect to the Analyzer
%  obj.Auto_Tune()                      Auto tune the frequency(Spectrogram) window in case of errors
%  obj.Mode_Preset()                    Mode Preset (Returns the active mode to a known state) 
%  obj.Set_Center_Frequency(3.5e9)      set the center frequency to 1GHz
%  obj.Set_BnadWidth(3.0e6)             set BW to 3MHz
%  obj.Set_Span(7.0e9)                  Set Span size to 10Mz
%  obj.Set_Marker_onPeak(1)             set marker on a peak(constant peak search)
%  obj.Peak_Search(1)                   Peak Search (Sending this command selects the subopcoded marker)
%  obj.Set_Marker(1)                    put the marker on the screen
%  obj.Turn_off_Marker(1)               remove the marker from the screen
%  obj.Turn_off_All_Markers()           remove all the markers from the screen 
%  obj.Next_Position(1)                 Move marker to the next position
%  obj.Next_Peake_Right(1)              Move marker to the next Right position
%  obj.Next_Peake_Left(1)               Move marker to the next Left position
%  obj.Get_Marker_Power(1)              Get the power value of marker1
%  obj.Get_Marker_Freq(1)               Get the frequency value of Marker1
%  obj.Disconnect_Analyzer()            Disconnect

 
classdef Analyzer_EXA_N9010A
    properties
        interface = 0;
    end
    methods
        function obj = Analyzer_EXA_N9010A()
            obj.interface = instrfind('Type', 'visa-tcpip', 'RsrcName', 'TCPIP0::192.168.6.6::inst0::INSTR', 'Tag', '');
            if isempty(obj.interface)
                 obj.interface = visa('KEYSIGHT', 'TCPIP0::192.168.6.6::inst0::INSTR');
            else
                fclose(obj.interface);
                obj.interface = obj.interface(1);
            end
            fopen(obj.interface);
        end
        
                % Established the connection        
%---------------------------------------------------------------------------------------------%   
                % scpi commands
                
        
     %! Auto Tune the Frequency(Spectrogram) window          
        function Auto_Tune(obj)
            command0 = sprintf(':FREQuency:TUNE:IMMediate');
            fprintf(obj.interface, command0);
        end
        
     %! Mode Preset (Returns the active mode to a known state)          
        function Mode_Preset(obj)
            command0 = sprintf(':SYSTem:PRESet');
            fprintf(obj.interface, command0);
        end        
                
     %! set BW
        function Set_BnadWidth(obj, fre)
            command0 = sprintf(':bandwidth:RES %eHz', fre);
            fprintf(obj.interface, command0);
        end
        
     %! set center Frequecy        
        function Set_Center_Frequency(obj, fre)
            
            command0 = sprintf(':FREQuency:CENTer %eHz', fre);
            fprintf(obj.interface, command0);
        end
        
     %! set the Span         
        function Set_Span(obj, fre)
            command0 = sprintf(':FREQuency:SPAN %eHz', fre);
            fprintf(obj.interface, command0);
        end
          
     %! set Marker on the Peak (constant peak search command)        
        function Set_Marker_onPeak(obj, id)
            command0 = sprintf(':Calculate:Marker%d:CPSearch 1', id);
            fprintf(obj.interface, command0);
        end
        
     %! Peak Search (Sending this command selects the subopcoded marker)        
        function Peak_Search(obj, id)
            command0 = sprintf(':Calculate:Marker%d:MAXimum', id);
            fprintf(obj.interface, command0);
        end        
                        
     %! turn On the marker (number of markers are possible just change the number in the bracket)         
        function Set_Marker(obj, id)      % select the marker number (1,2,3.....)
            command0 = sprintf(':Calculate:Marker%d:STATe 1', id);
            fprintf(obj.interface, command0);
        end
               
     %! turn Off only selected marker          
        function Turn_off_Marker(obj, id)     % select the marker number (1,2,3.....)
            command0 = sprintf(':Calculate:Marker%d:STATe 0', id);
            fprintf(obj.interface, command0);
        end        
        
     %! All markers OFF          
        function Turn_off_All_Markers(obj)
            command0 = sprintf(':Calculate:Marker:AOFF');
            fprintf(obj.interface, command0);
        end        
        
      %! move A marker to the Next Position
         function Next_Position(obj, id)
            command0 = sprintf(':CALCulate:Marker%d:MAXimum:NEXT', id);
            fprintf(obj.interface, command0);
         end
           
      %! move the marker Next Right Position
           function Next_Peake_Right(obj, id)
                command0 = sprintf(':CALCulate:Marker%d:MAXimum:RIGHT', id);
                fprintf(obj.interface, command0);
            end
   
      %! move the marker Next Left Position
           function Next_Peake_Left(obj, id)
                command0 = sprintf(':CALCulate:Marker%d:MAXimum:LEFT', id);
                fprintf(obj.interface, command0);
           end    
 
     %! Get the Power of the Marker        
        function Power = Get_Marker_Power(obj, id)
            command0 = sprintf(':CALCulate:MARKer%d:Y?', id);
            Power = query(obj.interface, command0);
        end
                
     %! Get the Frequency of the Marker       
        function fre = Get_Marker_Freq(obj, id)
            command0 = sprintf(':CALCulate:MARKer%d:X?', id);
            fre = query(obj.interface, command0);
        end

        
     %! save the data        
%         function data = saveData(obj)
%             options = weboptions('Timeout',Inf);
%             fileName = 'tmp.csv';
%             urlstr = sprintf('http://%s/Agilent.SA.WebInstrument/Trace1.csv', obj.ipAddress);
%             outfilename = websave(fileName, urlstr, options);
%             data = csvread('tmp.csv', 44,0);
%         end

        % disconnect the device
        function Disconnect_Analyzer(obj)
            fclose(obj.interface);
        end
    end
end
