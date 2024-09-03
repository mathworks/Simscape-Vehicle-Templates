
load_system('Linkage_Systems')
set_param(bdroot,'Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks('Linkage_Systems/Linkage',f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system('Linkage_Systems')
bdclose('Linkage_Systems')

%%
load_system('Linkage_Decoupled')
set_param('Linkage_Decoupled','Lock','off')

f = Simulink.FindOptions('SearchDepth',1);
linkageBlocks = Simulink.findBlocks('Linkage_Decoupled_Systems/Linkage',f);

for i = 1:length(linkageBlocks)
    if(strcmp(get_param(linkageBlocks(i),'LinkStatus'),'unresolved'))
        disp(getfullname(linkageBlocks(i)));
        delete_block(linkageBlocks(i))
    end
end

save_system('Linkage_Decoupled_Systems')
bdclose('Linkage_Decoupled_Systems')
