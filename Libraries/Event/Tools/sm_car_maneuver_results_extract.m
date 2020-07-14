getPose_simres_matrix  = logsout_sm_car.get('getPose_simres');
getPose_simres_vec = reshape(getPose_simres_matrix.Values.Data(:)',12,[])';
getPose_t = getPose_simres_matrix.Values.Time;
idx_ptRev = getPose_simres_vec(:,1);
idx_ptFwd = getPose_simres_vec(:,2);
ld_ptRev = getPose_simres_vec(:,3);
ld_ptMin = getPose_simres_vec(:,4);
ld_ptFwd = getPose_simres_vec(:,5);
idx_a = getPose_simres_vec(:,6);
idx_b = getPose_simres_vec(:,7);
ld = getPose_simres_vec(:,8);
ad = getPose_simres_vec(:,9);
dist2fwdpt = getPose_simres_vec(:,10);
cos_ang = getPose_simres_vec(:,11);

figure(99)
plot(getPose_t,idx_ptRev,getPose_t,idx_ptFwd)
