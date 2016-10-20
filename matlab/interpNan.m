function Y = interpNan(X)

[r,c]=size(X);
Xa = nan(size(X));
for i=1:r
    val = X(i,:);
    ind = find(~isnan(val));
    if numel(ind)>2
        Xa(i,:) = interp1(ind,val(ind),1:numel(val),'linear','extrap');
    end
end

Xb = nan(size(X));
for i=1:c
    val = X(:,i);
    ind = find(~isnan(val));
    if numel(ind)>2
        Xb(:,i) = interp1(ind,val(ind),1:numel(val),'linear','extrap');
    end
end

T = ~isnan(Xa)+~isnan(Xb);
Xa(isnan(Xa))=0;
Xb(isnan(Xb))=0;
Y = (Xa + Xb) ./ T;

end