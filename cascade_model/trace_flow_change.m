function [delta_r, delta_g] = trace_flow_change(prev_mpc, current_mpc, ovl)
% Return the value of power change on given line due to rerouting and/or
% generation and demand change.

define_constants;

tol = 1e-8;

% RATE_A = 6;
% 
% 
% 
% if ~isnan(line_index)
%     fprintf('(inside) flow = %f, RATE_A = %f\n', ...
%         current_mpc.branch(line_index,PF), ...
%         current_mpc.branch(line_index,RATE_A));
% end
% 
% % current_mpc.order.branch.status.off
% 
% % Convert to internal linear indexing of buses
% prev_mpc = ext2int(prev_mpc);
% current_mpc = ext2int(current_mpc);
% 
% 
% if ~isnan(line_index)
%     fprintf('(inside) flow = %f, RATE_A = %f\n', ...
%         current_mpc.branch(line_index,PF), ...
%         current_mpc.branch(line_index,RATE_A));
% end
% % current_mpc.order.branch.status.off

% Create mapping between bus numbers and linear row index for prev_mpc.bus
i2b = prev_mpc.bus(:,BUS_I);
b2i = zeros(max(prev_mpc.bus(:,BUS_I)),1);
for k = 1:size(prev_mpc.bus,1)
    b2i(prev_mpc.bus(k,BUS_I)) = k;
end

% fprintf('norm(prev_mpc.gen(:,PG) - current_mpc.gen(:,PG)) = %g\n', ...
%     norm(prev_mpc.gen(:,PG) - current_mpc.gen(:,PG)));
    
% Compute Pn(i) = nodal power flow = (sum of incoming line flows) +
% generation
n = size(prev_mpc.bus,1);
P = zeros(n,1);
for i = 1:n 
    from_i = prev_mpc.branch(:,F_BUS) == i2b(i) & prev_mpc.branch(:,PF) < -tol & prev_mpc.branch(:,BR_STATUS);
  	to_i = prev_mpc.branch(:,T_BUS) == i2b(i) & prev_mpc.branch(:,PT) < -tol & prev_mpc.branch(:,BR_STATUS);
    P(i) = sum(abs(prev_mpc.branch(from_i, PF))) ...
        + sum(abs(prev_mpc.branch(to_i, PT)));
end
Pg = zeros(n,1);
for i = 1 : size(prev_mpc.gen,1)
    if prev_mpc.gen(i,GEN_STATUS) > 0
        k = b2i(prev_mpc.gen(i,GEN_BUS)); % linear index of the bus
        Pg(k) = Pg(k) + prev_mpc.gen(i,PG);
    end
end
P = P + Pg;

% Compute coefficients c(j,i) [= c_ji in the notation of the Bialek paper]
nl = size(prev_mpc.branch,1);
Pji = zeros(n);
for k = 1:nl
    if prev_mpc.branch(k,BR_STATUS)
        f_bus = prev_mpc.branch(k,F_BUS);
        t_bus = prev_mpc.branch(k,T_BUS);
        if prev_mpc.branch(k,PF) < -tol
            j = b2i(t_bus); i = b2i(f_bus);
            Pji(j,i) = Pji(j,i) + abs(prev_mpc.branch(k,PF));
        elseif prev_mpc.branch(k,PF) > tol
            j = b2i(f_bus); i = b2i(t_bus);
            Pji(j,i) = Pji(j,i) + abs(prev_mpc.branch(k,PF));
        end % Treating as zero flow if between -tol and tol
    end
end
Pinv = zeros(size(P));
ix = find(abs(P) > tol);
Pinv(ix) = 1./P(ix);
c = diag(Pinv)*Pji;

% The matrix Au in the notation of the Bialek paper
A = eye(n) - c';

e = A*P-Pg;  
if norm(e) > tol
    fprintf('*** Error: norm(e) = %g\n', norm(e));
    save prev_mpc.mat
end

% Compute changes in generation
current_Pg = zeros(n,1);
for i = 1 : size(current_mpc.gen,1)
    if current_mpc.gen(i,GEN_STATUS) > 0
        k = b2i(current_mpc.gen(i,GEN_BUS));
        current_Pg(k) = current_Pg(k) + current_mpc.gen(i,PG);
    end
end
del_Pg = current_Pg - Pg;

% Compute the change in line flows due to generation change
del_P = A\del_Pg;
% fprintf(' ***norm(del_Pg) = %g, norm(del_P) = %g\n', norm(del_Pg), norm(del_P));
% fprintf(' *** max/min(del_P) = %.8f/%.8f\n', max(del_P), min(del_P));
delta_g = zeros(size(ovl));
delta_r = zeros(size(ovl));
delta = zeros(size(ovl));
for k = 1:length(ovl)
    li = ovl(k);
    f_bus = prev_mpc.branch(li, F_BUS);
    t_bus = prev_mpc.branch(li, T_BUS);
    if prev_mpc.branch(li, PF) > tol
        delta(k) = current_mpc.branch(li,PF) - prev_mpc.branch(li,PF);
        j = b2i(f_bus); %i = b2i(t_bus);
        if P(j) > tol
%           delta_g(k) = c(j,i)*del_P(j);
            delta_g(k) = prev_mpc.branch(li,PF)/P(j)*del_P(j);
        else
            delta_g(k) = 0;
        end
        delta_r(k) = delta(k) - delta_g(k);
%         fprintf(' %d (%d -> %d): prev = %f, curr = %f, RATE_A = %f\n', ...
%             ovl(k), f_bus, t_bus, ...
%             prev_mpc.branch(line_index,PF), ...
%             current_mpc.branch(line_index,PF), ...
%             current_mpc.branch(line_index,RATE_A));
    else
        delta(k) = current_mpc.branch(li,PT) - prev_mpc.branch(li,PT);
        j = t_bus; %i = f_bus;
        if P(j) > tol
%         delta_g(k) = c(j,i)*del_P(j);
            delta_g(k) = prev_mpc.branch(li,PT)/P(j)*del_P(j);
        else
            delta_g(k) = 0;
        end
        delta_r(k) = delta(k) - delta_g(k);
%         fprintf(' %d (%d -> %d): prev = %f, curr = %f, RATE_A = %f\n', ...
%             ovl(k), f_bus, t_bus, ...
%             prev_mpc.branch(line_index,PT), ...
%             current_mpc.branch(line_index,PT), ...
%             current_mpc.branch(line_index,RATE_A));
    end  
end

% fprintf('delta = %f, delta_g = %f, delta_r = %f\n', delta, delta_g, delta_r);
% if delta_r < tol
%     fprintf('gen_change = 1, rerouting = 0\n');
% elseif delta_g > tol
%     fprintf('gen_change = %f, rerouting = %f\n', ...
%         delta_g/delta,  delta_r/delta);
% else
%     fprintf('gen_change = 0, rerouting = 1\n');
% end

end