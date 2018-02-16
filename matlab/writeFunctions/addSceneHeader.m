function str = addSceneHeader(scenename,objectdb)

str = '<?xml version="1.0" encoding="UTF-8"?>\n';
str = [str sprintf('<scene name="%s" objectdb="%s" version = "1.0">\n',...
    scenename,objectdb)];

end