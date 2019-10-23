function pid = getmyPID()
%A getmyPID version that runs under Octave and 

if exist('getpid')==0
    pid=feature('getpid');
else
    pid=getpid();
end


end

