function r = deg2rad(d)
% deg2rad
%
% Description: convert degrees to radians: this function appears to be missing
%              on some Windows Matlab r2014a instances, thus it is included here
%              just in case
%
% Syntax: r = deg2rad(d)
%
% In:
%       d - angle in degrees
%
% Out:
%       r - input <d> converted to radians
%
% Updated: 2016-05-18
% Scottie Alexander

r = (d/180)*pi;
