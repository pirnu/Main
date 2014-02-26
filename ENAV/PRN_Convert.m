function New = PRN_Convert( Incoming )
%Converts the PRN sequence from 0's and 1's to 1's and -1's
New = ((Incoming==0)*1 + (Incoming==1)*(-1))*(-1);
end

