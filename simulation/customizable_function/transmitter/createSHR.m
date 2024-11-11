function [SHR, SYNC, SFD, SYNCbit, SFDbit] = createSHR(cfg)
% SYNC
% As per Sec. 15.2.6.2 in IEEE Std 802.15.4??\2020
code = HRPCodes(cfg.CodeIndex);
L = cfg.PreambleSpreadingFactor;
N = cfg.PreambleDuration;

% 1. Add L-1 zeros after each ternary (-1, 0, +1) symbol of the code
spread = zeros(L*length(code), 1);
spread(1:L:end) = code;

% 2. Repeat spread sequence N times (spread seq is also referred as a symbol)
SYNC = repmat(spread, N, 1);
SYNCbit = repmat(code', N, 1);

% SFD (Start of Frame delimiter)
% As per Sec. 15.2.6.3 in IEEE Std 802.15.4??\2020
seq = getSFD(cfg.SFDNumber);
SFD = seq.*spread;
SFD = SFD(:);
SFDbit = seq.*code';
SFDbit = SFDbit(:);

SHR = [SYNC; SFD];
end

function code = HRPCodes(codeIndex)
%lrwpan.internal.HRPCodes Get a specific preamble (SYNC) code sequence
%  CODE = lrpwan.internal.HRPCodes(CODEINDEX) returns a specific preamble
%  (SYNC) code sequence indexed by CODEINDEX as per Sec. 15.2.6.2. When
%  CODEINDEX is between 1 and 8, CODE is a 31-symbol sequence as per Table
%  15-6. When CODEINDEX is between 9 and 24, CODE is a 127-symbol sequence
%  as per Table 15-7. When CODEINDEX is between 25 and 32, CODE is a
%  91-symbol sequence as per Table 15-7a.

%   Copyright 2021-2022 The MathWorks, Inc.

%#codegen

persistent Codes

if isempty(Codes)

  Codes = { %% Length 31 - Table 15-6
    [-1 0 0 0 0 +1 0 -1 0 +1 +1 +1 0 +1 -1 0 0 0 +1 -1 +1 +1 +1 0 0 -1 +1 0 -1 0 0]; % 1
    [0 +1 0 +1 -1 0 +1 0 +1 0 0 0 -1 +1 +1 0 -1 +1 -1 -1 -1 0 0 +1 0 0 +1 +1 0 0 0]; % 2
    [-1 +1 0 +1 +1 0 0 0 -1 +1 -1 +1 +1 0 0 +1 +1 0 +1 0 0 -1 0 0 0 0 -1 0 +1 0 -1]; % 3
    [0 0 0 0 +1 -1 0 0 -1 0 0 -1 +1 +1 +1 +1 0 +1 -1 +1 0 0 0 +1 0 -1 0 +1 +1 0 -1]; % 4
    [-1 0 +1 -1 0 0 +1 +1 +1 -1 +1 0 0 0 -1 +1 0 +1 +1 +1 0 -1 0 +1 0 0 0 0 -1 0 0]; % 5
    [+1 +1 0 0 +1 0 0 -1 -1 -1 +1 -1 0 +1 +1 -1 0 0 0 +1 0 +1 0 -1 +1 0 +1 0 0 0 0]; % 6
    [+1 0 0 0 0 +1 -1 0 +1 0 +1 0 0 +1 0 0 0 +1 0 +1 +1 -1 -1 -1 0 -1 +1 0 0 -1 +1]; % 7
    [0 +1 0 0 -1 0 -1 0 +1 +1 0 0 0 0 -1 -1 +1 0 0 -1 +1 0 +1 +1 -1 +1 +1 0 +1 0 0]; % 8
    
    
    %% Length 127 - Table 15-7
    [+1 0 0 +1 0 0 0 -1 0 -1 -1 0 0 -1 -1 +1 0 +1 0 +1 0 0 -1 +1 -1 +1 +1 0 +1 0 0 ...
    0 0 +1 +1 -1 0 0 0 +1 0 0 -1 0 0 -1 -1 0 -1 +1 0 +1 0 -1 -1 0 -1 +1 +1 +1 0 +1 ...
    +1 0 0 0 +1 -1 0 +1 0 0 -1 0 +1 +1 -1 0 +1 +1 +1 0 0 -1 +1 0 0 +1 0 +1 0 -1 0 ...
    +1 +1 -1 +1 -1 -1 +1 0 0 0 0 0 0 +1 0 0 0 0 0 -1 +1 0 0 0 0 -1 0 -1 0 0 0 -1 -1 +1]; %9
    
    [+1 +1 0 0 +1 0 -1 +1 0 0 +1 0 0 +1 0 0 0 0 0 0 -1 0 0 0 -1 0 0 -1 -1 0 0 0 -1 0 +1 ...
    -1 +1 0 -1 0 +1 -1 0 -1 +1 0 0 0 0 0 +1 -1 0 0 +1 +1 0 -1 0 +1 0 0 -1 -1 +1 0 0 +1 ...
    +1 -1 +1 0 +1 -1 0 +1 0 0 0 0 -1 0 -1 0 -1 0 -1 +1 +1 -1 +1 0 +1 0 0 +1 0 +1 0 0 0 ...
    -1 +1 0 +1 +1 +1 0 0 0 -1 -1 -1 -1 +1 +1 +1 0 0 0 0 +1 +1 +1 0 -1 -1];             %10
    
    [-1 +1 -1 0 0 0 0 +1 0 0 -1 -1 0 0 0 0 0 -1 0 +1 0 +1 0 +1 -1 0 +1 0 0 +1 0 0 +1 ...
    0 -1 0 0 -1 +1 +1 +1 0 0 +1 0 0 0 -1 +1 0 +1 0 -1 0 0 0 0 +1 +1 +1 +1 +1 -1 +1 0 ...
    +1 -1 -1 0 +1 -1 0 +1 +1 -1 -1 0 -1 0 0 0 +1 0 -1 +1 0 0 +1 0 +1 -1 -1 -1 -1 0 0 ...
    0 -1 0 0 0 0 0 0 -1 +1 0 0 +1 -1 0 +1 +1 0 0 0 +1 +1 -1 0 0 +1 +1 -1 0 -1 0];      % 11
    
    [-1 +1 0 +1 +1 0 0 0 0 0 0 -1 0 +1 0 -1 +1 0 -1 -1 -1 +1 -1 +1 +1 0 0 -1 +1 0 ...
    +1 +1 0 +1 0 +1 0 +1 0 0 0 -1 0 0 -1 0 0 -1 +1 0 0 +1 -1 +1 +1 0 0 0 -1 +1 -1 0 ...
    -1 +1 +1 0 -1 0 +1 +1 +1 +1 0 -1 0 0 -1 0 +1 +1 0 0 +1 0 +1 0 0 +1 +1 -1 0 0 ...
    +1 0 0 0 +1 -1 0 0 0 -1 0 -1 -1 +1 0 0 0 0 -1 0 0 0 0 -1 -1 0 +1 0 0 0 0 0 +1 -1 -1]; %12
    
    [+1 0 0 0 -1 -1 0 0 0 0 -1 -1 +1 +1 0 -1 +1 +1 +1 +1 0 -1 0 +1 +1 0 +1 0 -1 0 0 ...
    -1 +1 0 +1 +1 0 0 +1 +1 -1 0 +1 +1 0 +1 -1 +1 0 -1 0 0 +1 0 0 -1 0 -1 -1 0 0 0  ...
    -1 +1 -1 0 0 +1 0 0 0 0 -1 0 +1 +1 -1 0 0 0 0 0 +1 -1 0 -1 0 0 0 0 0 0 -1 0 0 -1 ...
    +1 -1 +1 +1 -1 +1 0 0 0 -1 0 +1 0 +1 0 +1 +1 +1 -1 0 0 -1 -1 0 0 +1 0 +1 0 0 0];     %13
    
    [+1 0 0 0 +1 +1 0 -1 0 +1 0 -1 0 0 +1 -1 0 -1 +1 0 -1 0 0 +1 0 +1 0 0 0 0 +1 0 ...
    +1 -1 0 0 0 0 +1 +1 0 0 +1 0 +1 +1 +1 +1 +1 -1 +1 0 -1 0 +1 -1 0 -1 -1 +1 0 +1 ...
    +1 -1 -1 0 0 0 -1 -1 -1 0 +1 0 0 0 +1 0 +1 0 -1 +1 -1 0 0 0 0 0 0 +1 -1 +1 -1 ...
    0 -1 -1 0 0 +1 +1 0 0 0 -1 0 0 +1 0 0 +1 +1 -1 0 0 -1 -1 +1 +1 -1 0 0 -1 0 0 0 0 0]; %14
    
    [0 +1 -1 0 0 +1 0 -1 0 0 0 -1 +1 +1 0 0 0 0 -1 -1 -1 +1 +1 0 0 0 +1 0 +1 -1 0 -1 ...
    +1 0 0 -1 +1 0 0 0 -1 -1 0 -1 0 0 -1 -1 0 -1 -1 +1 +1 +1 -1 +1 0 -1 +1 +1 0 0 +1 ...
    -1 +1 +1 0 +1 0 0 0 0 0 +1 0 -1 0 +1 +1 +1 -1 0 0 +1 0 0 +1 0 0 0 -1 0 0 0 0 +1 ...
    0 0 -1 -1 +1 0 +1 +1 0 +1 0 +1 0 -1 0 0 -1 0 -1 +1 -1 0 +1 0 +1 +1 0 0 0 0 0];     % 15
    
    [+1 +1 0 0 0 0 +1 0 0 0 +1 0 0 +1 -1 -1 0 +1 -1 +1 +1 0 -1 0 0 0 -1 -1 0 0 +1 -1 ...
    0 +1 0 0 +1 +1 0 0 0 +1 +1 +1 0 0 +1 0 +1 0 -1 0 -1 +1 -1 0 -1 0 +1 0 0 +1 0 0 +1 ...
    0 +1 +1 -1 -1 -1 -1 +1 0 0 +1 +1 -1 -1 +1 0 +1 -1 0 -1 -1 +1 0 0 0 0 0 0 -1 0 -1 ...
    0 0 0 0 -1 +1 0 -1 -1 0 0 +1 0 0 0 0 0 +1 -1 +1 +1 0 0 0 -1 0 -1 +1 0 +1 0];       % 16
    
    [+1 -1 -1 0 0 0 -1 0 -1 0 0 0 0 +1 -1 0 0 0 0 0 +1 0 0 0 0 0 0 +1 -1 -1 +1 -1 +1 ...
    +1 0 -1 0 +1 0 +1 0 0 +1 -1 0 0 +1 +1 +1 0 -1 +1 +1 0 -1 0 0 +1 0 -1 +1 0 0 0 +1 ...
    +1 0 +1 +1 +1 -1 0 -1 -1 0 +1 0 +1 -1 0 -1 -1 0 0 -1 0 0 +1 0 0 0 -1 +1 +1 0 0 0 ...
    0 +1 0 +1 +1 -1 +1 -1 0 0 +1 0 +1 0 +1 -1 -1 0 0 -1 -1 0 -1 0 0 0 +1 0 0 +1];      % 17
    
    [-1 -1 0 +1 +1 +1 0 0 0 0 +1 +1 +1 -1 -1 -1 -1 0 0 0 +1 +1 +1 0 +1 -1 0 0 0 +1 ...
    0 +1 0 0 +1 0 +1 -1 +1 +1 -1 0 -1 0 -1 0 -1 0 0 0 0 +1 0 -1 +1 0 +1 -1 +1 +1 0 ...
    0 +1 -1 -1 0 0 +1 0 -1 0 +1 +1 0 0 -1 +1 0 0 0 0 0 +1 -1 0 -1 +1 0 -1 0 +1 -1 +1 ...
    0 -1 0 0 0 -1 -1 0 0 -1 0 0 0 -1 0 0 0 0 0 0 +1 0 0 +1 0 0 +1 -1 0 +1 0 0 +1 +1];   % 18
    
    [-1 0 -1 +1 +1 0 0 -1 +1 +1 0 0 0 +1 +1 0 -1 +1 0 0 +1 -1 0 0 0 0 0 0 -1 0 0 0 ...
    -1 -1 -1 -1 +1 0 +1 0 0 +1 -1 0 +1 0 0 0 -1 0 -1 -1 +1 +1 0 -1 +1 0 -1 -1 +1 0 ...
    +1 -1 +1 +1 +1 +1 +1 0 0 0 0 -1 0 +1 0 +1 -1 0 0 0 +1 0 0 +1 +1 +1 -1 0 0 -1 ...
    0 +1 0 0 +1 0 0 +1 0 -1 +1 0 +1 0 +1 0 -1 0 0 0 0 0 -1 -1 0 0 +1 0 0 0 0 -1 +1 -1 0]; % 19
    
    [-1 -1 +1 0 0 0 0 0 +1 0 -1 -1 0 0 0 0 -1 0 0 0 0 +1 -1 -1 0 -1 0 0 0 -1 +1 0 0 0 ...
    +1 0 0 -1 +1 +1 0 0 +1 0 +1 0 0 +1 +1 0 -1 0 0 -1 0 +1 +1 +1 +1 0 -1 0 +1 +1 -1 0 ...
    -1 +1 -1 0 0 0 +1 +1 -1 +1 0 0 +1 -1 0 0 -1 0 0 -1 0 0 0 +1 0 +1 0 +1 0 +1 +1 0 +1 ...
    -1 0 0 +1 +1 -1 +1 -1 -1 -1 0 +1 -1 0 +1 0 -1 0 0 0 0 0 0 +1 +1 0 +1 -1];             % 20
    
    [+1 0 +1 0 0 -1 -1 0 0 -1 +1 +1 +1 0 +1 0 +1 0 -1 0 0 0 +1 -1 +1 +1 -1 +1 -1 0 0 ...
    -1 0 0 0 0 0 0 -1 0 -1 +1 0 0 0 0 0 -1 +1 +1 0 -1 0 0 0 0 +1 0 0 -1 +1 -1 0 0 0 ...
    -1 -1 0 -1 0 0 +1 0 0 -1 0 +1 -1 +1 0 +1 +1 0 -1 +1 +1 0 0 +1 +1 0 +1 -1 0 0 -1 ...
    0 +1 0 +1 +1 0 -1 0 +1 +1 +1 +1 -1 0 +1 +1 -1 -1 0 0 0 0 -1 -1 0 0 0 +1 0 0 0];       % 21
    
    [0 -1 0 0 -1 +1 +1 -1 -1 0 0 -1 +1 +1 0 0 +1 0 0 -1 0 0 0 +1 +1 0 0 -1 -1 0 -1 +1 ...
    -1 +1 0 0 0 0 0 0 -1 +1 -1 0 +1 0 +1 0 0 0 +1 0 -1 -1 -1 0 0 0 -1 -1 +1 +1 0 +1 -1 ...
    -1 0 -1 +1 0 -1 0 +1 -1 +1 +1 +1 +1 +1 0 +1 0 0 +1 +1 0 0 0 0 -1 +1 0 +1 0 0 0 0 +1 ...
    0 +1 0 0 -1 0 +1 -1 0 -1 +1 0 0 -1 0 +1 0 -1 0 +1 +1 0 0 0 +1 0 0 0 0];               % 22
    
    [0 0 0 +1 +1 0 +1 0 -1 +1 -1 0 -1 0 0 -1 0 +1 0 +1 0 +1 +1 0 +1 -1 -1 0 0 +1 0 0 0 ...
    0 -1 0 0 0 +1 0 0 +1 0 0 -1 +1 +1 +1 0 -1 0 +1 0 0 0 0 0 +1 0 +1 +1 -1 +1 0 0 +1 +1 ...
    -1 0 +1 -1 +1 +1 +1 -1 -1 0 -1 -1 0 0 -1 0 -1 -1 0 0 0 +1 -1 0 0 +1 -1 0 -1 +1 0 +1 ...
    0 0 0 +1 +1 -1 -1 -1 0 0 0 0 +1 +1 -1 0 0 0 -1 0 +1 0 0 -1 +1 0 0 0];                 % 23
    
    [+1 0 +1 -1 0 -1 0 0 0 +1 +1 -1 +1 0 0 0 0 0 +1 0 0 -1 -1 0 +1 -1 0 0 0 0 -1 0 -1 0 ...
    0 0 0 0 0 +1 -1 -1 0 -1 +1 0 +1 -1 -1 +1 +1 0 0 +1 -1 -1 -1 -1 +1 +1 0 +1 0 0 +1 0 0 ...
    +1 0 -1 0 -1 +1 -1 0 -1 0 +1 0 +1 0 0 +1 +1 +1 0 0 0 +1 +1 0 0 +1 0 -1 +1 0 0 -1 -1 ...
    0 0 0 -1 0 +1 +1 -1 +1 0 -1 -1 +1 0 0 +1 0 0 0 +1 0 0 0 0 +1 +1 0];                   % 24
    
    
    %% Length 91 - Table 15-7a
    [-1 0 +1 +1 +1 +1 -1 -1 +1 -1 -1 +1 -1 +1 +1 +1 +1 -1 +1 -1 -1 -1 +1 +1 -1 -1 +1 +1 ...
    +1 +1 +1 +1 -1 +1 +1 -1 +1 0 0 +1 -1 -1 +1 0 -1 -1 +1 0 +1 +1 +1 +1 +1 -1 -1 +1 ...
    +1 +1 -1 -1 0 -1 -1 0 +1 -1 +1 -1 -1 -1 -1 0 -1 +1 -1 +1 -1 +1 0 +1 -1 -1 +1 +1 -1 +1 ...
    -1 +1 +1 +1 0]; % 25
    
    [+1 +1 0 +1 -1 +1 -1 -1 -1 +1 +1 +1 +1 +1 -1 +1 -1 +1 +1 -1 -1 +1 -1 -1 +1 +1 -1 -1 -1 ...
    +1 -1 0 +1 +1 +1 0 -1 +1 +1 +1 +1 -1 +1 0 +1 0 -1 -1 0 +1 -1 +1 +1 -1 +1 +1 +1 +1 +1 +1 ...
    -1 -1 +1 -1 +1 +1 0 0 +1 +1 +1 -1 -1 0 +1 -1 -1 -1 -1 -1 +1 -1 0 +1 -1 +1 -1 +1 -1 -1 -1]; % 26
    
    [+1 +1 +1 -1 -1 +1 +1 +1 -1 -1 -1 +1 -1 +1 -1 0 -1 +1 -1 -1 0 +1 +1 -1 +1 -1 +1 0 -1 +1 ...
    +1 +1 +1 +1 +1 +1 +1 +1 +1 -1 -1 +1 -1 -1 +1 +1 -1 +1 +1 0 +1 +1 -1 +1 -1 +1 -1 -1 +1  ...
    -1 -1 +1 +1 +1 -1 -1 -1 0 -1 +1 +1 +1 -1 0 +1 0 0 -1 -1 -1 +1 +1 -1 +1 -1 -1 0 -1 +1 +1 0]; % 27
    
    [+1 +1 +1 +1 +1 -1 -1 +1 +1 +1 -1 +1 +1 -1 -1 -1 +1 -1 +1 -1 -1 0 +1 +1 -1 -1 -1 +1 -1 +1 0 ...
    +1 -1 -1 -1 -1 -1 +1 0 +1 +1 +1 -1 -1 +1 -1 +1 -1 -1 +1 -1 +1 +1 -1 +1 +1 +1 +1 0 -1 0 -1 +1 ...
    +1 0 0 +1 -1 +1 +1 +1 -1 +1 +1 -1 +1 0 -1 +1 0 -1 -1 +1 -1 -1 -1 +1 +1 +1 0 +1]; % 28
    
    [+1 -1 0 -1 -1 +1 -1 +1 +1 -1 -1 0 +1 +1 0 0 +1 +1 -1 +1 +1 -1 -1 -1 -1 -1 +1 +1 +1 +1 ...
    +1 +1 -1 0 +1 -1 -1 +1 -1 +1 +1 -1 -1 +1 -1 +1 +1 +1 -1 -1 +1 +1 +1 +1 +1 +1 +1 -1 +1 +1 ...
    +1 0 +1 -1 +1 -1 0 -1 0 -1 +1 +1 -1 -1 -1 +1 0 -1 -1 -1 +1 +1 0 -1 +1 -1 +1 -1 +1 +1 -1]; % 29
    
    [-1 +1 +1 0 -1 -1 0 +1 +1 -1 0 0 -1 -1 +1 +1 -1 +1 +1 -1 +1 -1 -1 +1 +1 +1 +1 +1 -1 -1 ...
    -1 +1 +1 +1 -1 +1 -1 0 +1 -1 +1 -1 +1 0 +1 +1 +1 +1 +1 -1 +1 +1 +1 -1 +1 +1 +1 -1 +1 0 ...
    -1 -1 -1 -1 -1 -1 +1 +1 -1 +1 +1 -1 +1 0 -1 -1 -1 -1 +1 -1 +1 -1 0 +1 0 +1 -1 +1 +1 +1 -1]; % 30
    
    [-1 +1 -1 +1 +1 0 +1 +1 +1 -1 -1 +1 +1 -1 0 +1 +1 0 0 -1 -1 +1 +1 -1 -1 +1 +1 +1 -1 +1 ...
    -1 -1 -1 -1 -1 -1 0 +1 +1 +1 -1 +1 +1 +1 +1 +1 -1 -1 +1 -1 +1 +1 -1 -1 -1 +1 -1 +1 -1 ...
    -1 -1 +1 -1 +1 0 -1 +1 -1 -1 0 +1 0 +1 -1 +1 +1 -1 +1 +1 0 +1 -1 +1 -1 -1 0 +1 +1 +1 +1 +1]; % 31
    
    [-1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 -1 -1 -1 +1 -1 +1 +1 -1 -1 +1 +1 0 0 -1 +1 -1 +1 0 ...
    -1 +1 -1 0 -1 +1 +1 -1 -1 +1 +1 +1 -1 +1 +1 +1 0 -1 -1 0 +1 +1 -1 +1 -1 +1 -1 0 -1 -1 -1 ...
    +1 +1 -1 0 -1 -1 -1 -1 +1 +1 +1 +1 -1 +1 -1 0 +1 0 -1 +1 -1 +1 +1 -1 +1 +1 -1 -1 +1 -1]; % 32
    };
end

code = Codes{codeIndex};
end

function SFD = getSFD(SFDNumber)
%lrwpan.internal.getSFD Get the applicable SFD sequence
%  SFD = lrpwan.internal.getSFD(CFG) returns the SFD sequence that applies
%  for the given operational mode (HPRF, BPRF, or 802.15.4a) and SFD index
%  or data rate, as specified in the input <a
%  href="matlab:help('lrwpanHRPConfig')">lrwpanHRPConfig</a> object CFG.
%  The length of the output sequence SFD is either 4, 8, 16, 32 or 64
%  symbols long.

%   Copyright 2021-2022 The MathWorks, Inc.

%#codegen
  % Table 15-7c
switch SFDNumber
case 0
	SFD = [0 +1 0 -1 +1 0 0 -1]; % legacy
case 1
  SFD = [-1 -1 +1 -1];
case 2
  SFD = [-1 -1 -1 +1 -1 -1 +1 -1];
case 3
  SFD = [-1 -1 -1 -1 -1 +1 +1 -1 -1 +1 -1 +1 -1 -1 +1 -1];
otherwise % case 4
  SFD = [-1 -1 -1 -1 -1 -1 -1 +1 -1 -1 +1 -1 -1 +1 -1 +1 -1 +1 ...
-1 -1 -1 +1 +1 -1 -1 -1 +1 -1 +1 +1 -1 -1];
end  

end