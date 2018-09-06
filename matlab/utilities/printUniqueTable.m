function printUniqueTable(varname,x,n)
if nargin==2
    n=0;
end

fprintf('%20s: ',varname);
uniquex = unique(x);
for i=1:numel(uniquex)
   fprintf('%6g | ',uniquex(i)); 
end
for j = i:n
   fprintf('%6s | ',''); 
end
fprintf('\n');

end