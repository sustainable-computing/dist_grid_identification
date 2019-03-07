function [Y] = constructYMatrix(DSSObj)
% FUNCTION constructYMatrix: load and format the network admittance matrix 
% via the OpenDSS interface 

% INPUT: 
% DSSObj: OpenDSS COM Object used to obtain Ymatrix for the specified model

% OUTPUT:
% Y: the three-phase nodal admittance matrix

DSSCircuit = DSSObj.ActiveCircuit;
nNodes = length(DSSCircuit.YNodeOrder);
DSSText = DSSObj.Text;

% disconnecting loads and generators to obtain a Y matrix that does not
% include the norton equivalent of the loads

DSSText.Command = 'vsource.source.enabled = no';
DSSText.Command = 'batchedit load..* enabled=no';

DSSCircuit.Solution.Solve;

% return an array of doubles representing a square complex matrix; (re, im) pairs in column order
Ybus = DSSCircuit.SystemY;
Y = reshape(Ybus,nNodes*2,nNodes)';

% create complex polyphase nodal Y
Y = Y(:,1:2:(nNodes*2)) + 1i*Y(:,2:2:nNodes*2); 

% optimize storage
% Y = sparse(Y);

% reconnecting loads and generators

DSSText.Command = 'vsource.source.enabled = yes';
DSSText.command = 'batchedit load..* enabled=yes';

end
