function matlab_data_wrapper(params,results)

% ~~~ for initial testing purposes ~~~
%clear;  clc;
%params = 'params.input';
%results = 'results.output';
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%--------------------------------------------------------------
% Set any fixed/default values needed for your analysis .m code
%--------------------------------------------------------------

% alpha = [];  % placeholder, if needed

%------------------------------------------------------------------
% READ params.in (or params.in.num) from DAKOTA and set Matlab variables
%
% read params.in (no aprepro) -- just one param per line
% continuous design, then U.C. vars
% --> 1st cell of C has values, 2nd cell labels
% --> variables are in rows 2-->?
%------------------------------------------------------------------

fid = fopen(params,'r');
C = textscan(fid,'%n%s');
fclose(fid);

num_vars = C{1}(1);

% set design variables -- could use vector notation
% beam deflection calc random variables

% continuous design variables
    X(1) = C{1}(2);     % length, default value = 2.0
    X(2) = C{1}(3);     % height, default value = 0.05
    X(3) = C{1}(4);     % width at support, default value = 0.20
    X(4) = C{1}(5);     % width at tip, default value = 0.10
    X(5) = C{1}(6);     % elastic modulus, default value = 69.1e9
    X(6) = C{1}(7);     % load, default value = 500    

% discrete variables, could go here    
    
% distributed uncertain variables, could go here

%------------------------------------------------------------------
% CALL analysis code to get the function value
%------------------------------------------------------------------

[Y] = f_bernoulli_euler_beam(X);


%------------------------------------------------------------------
% WRITE results.out
%------------------------------------------------------------------
fid = fopen(results,'w');
fprintf(fid,'%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \t%4.4f \td', Y.');
%fprintf(fid,'%20.10e     params\n', C{1}(2:5));

fclose(fid);

% alternately
%save(results,'vContact','-ascii');
