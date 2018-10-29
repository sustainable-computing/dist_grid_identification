function operateSwitches(topoID, DSSObj)

% Define the text interface
DSSText = DSSObj.Text;

% Syntax: Open [Object] [Term] [Cond] 
% Usecase: opens phase conductor Cond of terminal Term of Object
% if Cond is omitted all phase conductors are opened at once

if topoID == 123
    DSSText.Command = 'Open Line.Sw2 2';
    DSSText.Command = 'Close Line.Sw7 2'; 
    
    %DSSText.Command = 'Line.Sw7.Bus2=300';
elseif  topoID == 13
    DSSText.Command = 'Open Line.671675 2';
    DSSText.Command = 'Close Line.675680 2'; 
    
    %DSSText.Command = 'Open Line.671692 2'; 
else
   DSSText.Command = 'New fault.testflt bus1=645 phases=2'; 
end

DSSText.Command = 'Solve mode=snap';

end
