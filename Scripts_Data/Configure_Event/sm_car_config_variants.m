function sm_car_config_variants(blk)

opts = Simulink.FindOptions;
opts.LookUnderMasks = 'none';
opts.SearchDepth = 1;
opts.MatchFilter = @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices;
blks = Simulink.findBlocks(blk,'BlockType','SubSystem','Mask','on',opts); % Should find a more optimal way to find only the needed subsystems
for i = 1:length(blks)
     
    try% Putting a try catch here because some variants inside SuspA1 are erroring out, converting like what I did to suspA1 would fix that
        Simulink.Block.eval(blks(i));
        sm_car_config_variants(blks(i));
        %disp(getfullname(blks(i)))
    end
end