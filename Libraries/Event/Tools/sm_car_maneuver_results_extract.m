getPose_simres_matrix  = logsout_sm_car.get('getPose_simres');
getPose_simres_vec = reshape(getPose_simres_matrix.Values.Data(:)',12,[])';
getPose_t = getPose_simres_matrix.Values.Time;
idx_ptRev = getPose_simres_vec(:,1);
idx_ptMin = getPose_simres_vec(:,2);
idx_ptFwd = getPose_simres_vec(:,3);
ld_ptRev = getPose_simres_vec(:,4);
ld_ptMin = getPose_simres_vec(:,5);
ld_ptFwd = getPose_simres_vec(:,6);
idx_a = getPose_simres_vec(:,7);
idx_b = getPose_simres_vec(:,8);
ld = getPose_simres_vec(:,9);
ad = getPose_simres_vec(:,10);
dist2fwdpt = getPose_simres_vec(:,11);
cos_ang = getPose_simres_vec(:,12);

%,getPose_t,idx_ptRev,getPose_t,idx_ptFwd

figure(104)
ah(1) = subplot(411);
plot(getPose_t,idx_a,getPose_t,idx_b);
ah(2) = subplot(412);
plot(getPose_t,ad);
ah(3) = subplot(413);
plot(getPose_t,dist2fwdpt);
ah(4) = subplot(414);
plot(getPose_t,cos_ang);
%plot(dist_car.Time,dist_car.Data);
linkaxes(ah,'x');

