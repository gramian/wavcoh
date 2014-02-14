function wavcoh(filename,series1,series2,start,stop,sampl,minfreq,maxfreq)
% wavcoh (version: 1.2)
% by Christian Himpe 2011,2012,2013,2014
% licensed under BSD 2-Clause License
%
% about: encapsulation of wcoher command to visualize the wavelet coherence of two timeseries.
%
% usage: wavcoh(filename,series1,series2,start,stop,sampl,minfreq,maxfreq)
%
% parameters:
%	filename - datafile (either .mat or .txt/.csv/.dat whatever as long as it is in column sorted csv format)
%	series1  - name of first data column (text name for .mat (matlab) files, column number for txt/csv files)
%	series2  - name of second data column (text name for .mat (matlab) files, column number for txt/csv files)
%	start    - start index (practically the line of data to start with, if zero first index is used)
%	stop     - stop index (practically the line of data to stop at, if zero last index is used)
%	sampl    - sampling period (time in seconds between to data points)
%	minfreq  - lower bound to frequency range (in Hertz)
%	maxfreq  - upper bound to frequency range (in Hertz)
%
% !Requires MATLAB wavelet toolbox!
%*

%check if file exists
if(exist(filename,'file')==0) error(['ERROR: File not found: ' filename]); end
%*

%test for mat extension and load matlab binary formatted data
[PATH,NAME,EXTENSION] = fileparts(filename);
if(strcmp(EXTENSION,'.mat'))
        TABLE = load(filename,series1,series2);
	COL1 = eval(['TABLE.',series1]);
	COL2 = eval(['TABLE.',series2]);

	if(start<=0)
	   start = 1;
	end;

	if(stop<=0)
	   stop = length(COL1(:,1));
	end;

        COL1 = COL1(start:stop,1);
        COL2 = COL2(start:stop,1);

%test for txt extension to load csv formatted data
elseif( strcmp(EXTENSION,'.txt') || strcmp(EXTENSION,'.dat') || strcmp(EXTENSION,'.csv') )
        TABLE = importdata(NAME,',');

        COL1 = TABLE(start:stop,series1);
        COL2 = TABLE(start:stop,series2);

else
	error(['Error: Unrecognized Filetype: ' EXTENSION]);
end
%*

%choose Wavelet family and order as well as scale minimum and scale maximum
WLET = 'cgau3';
SMIN = (centfrq(WLET)/(minfreq*sampl));
SMAX = (centfrq(WLET)/(maxfreq*sampl));
%*

%assemble linearly spaced scale vector
DIFF = 200;
MSTP = (maxfreq-minfreq)/DIFF;
FRQC = minfreq;
SCLV = zeros(DIFF,1);
for I=1:DIFF
	SCLV(I) = (centfrq(WLET)/(FRQC*sampl));
	FRQC = FRQC + MSTP;
end
%*

%set up ytick and yticklabel vectors
YTCK = [SMAX SMAX+(SMIN-SMAX)*0.25 SMAX+(SMIN-SMAX)*0.50 SMAX+(SMIN-SMAX)*0.75 SMIN];
FTCK = [maxfreq minfreq+(maxfreq-minfreq)*0.75 minfreq+(maxfreq-minfreq)*0.50 minfreq+(maxfreq-minfreq)*0.25 minfreq];
%*

%compute wavelet coherence
SMTH = round((stop-start)*0.05);
[WCOH WCS] = wcoher(COL1,COL2,SCLV,WLET,'ntw',SMTH);
WCOH = abs(WCOH);
%*

%build image from matrix
OUT= image([start stop],[SMIN SMAX],WCOH,'CDataMapping','scaled');
CB = colorbar;
%*

%tweak plot
caxis([0 1]);
set(gca,'YTick',YTCK);
set(gca,'YTickLabel',FTCK);
set(get(CB,'ylabel'),'String','Coherence');
ylabel('Hz');
%*
