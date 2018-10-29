function [DSSObj, flag] = DSSStartup(PATH)
% FUNCTION DSSStartup: instantiate an OpenDSS object used to
% interact with the COM interface

% INPUT:
% path: path of the dss circuit model

% OUTPUT:
% DSSObj: the DSS object
% flag: boolean variable showing whether the DSS object instantiation is
% done successfully

DSSObj = actxserver('OpenDSSEngine.DSS');
flag = DSSObj.Start(0);
if flag
    DSSObj.Text.Command = ['compile ' PATH];
    DSSObj.Text.Command = 'MakeBusList';
else
    error('Fatal error!\n Failed to create the COM object to interface with OpenDSS');
end
