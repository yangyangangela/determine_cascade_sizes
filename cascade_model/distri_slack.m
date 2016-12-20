function new_mpc = distri_slack(old_mpc,flag)
% Re-adjust the output of slack bus.
% 1) if the slack bus generation > capacity
%   shed this amount of power with even rate on all the buses within same
%   zone
% 2) if the slack bus genration <0 (dmd < gen)
%
% Input: 
% flag 1: decrease generatrion evenly within same zone.
%        multiply the generator PG with rate = (dmd)/gen
% flag 2: increase demand evenly within same zone
%        multiply the demand with rate = gen/dmd

% tolerence unbalanced power
tol = .1;
new_mpc = old_mpc;

% some index
ZONE = 11;
GEN_STATUS = 8;
PMAX = 9;
PG = 2;
PD = 3;
GS = 5;

% default flag
if nargin < 2
    flag = 1;
end

%% Adjust the slack buses in the network. Each separate component in the network has its slack bus. 
SlackSet = find(old_mpc.bus(:,2)==3);

for s = 1 : length(SlackSet)
    
    % find the sub-network of the slack bus.
    slack = SlackSet(s);
    
    % bus index within community
    Cind = find(old_mpc.bus(:,ZONE)==old_mpc.bus(slack,ZONE));
    
    % index of generators that are on within community
    Gind = find(ismember(old_mpc.gen(:,1),old_mpc.bus(Cind,1))...
        & old_mpc.gen(:,GEN_STATUS)>0);
    
    % generator index of slack bus
    SlackGind = find(old_mpc.gen(:,1)==old_mpc.bus(slack,1)...
        & old_mpc.gen(:,GEN_STATUS)>0);
    
    % generators on slack bus
    gens = old_mpc.gen(SlackGind(old_mpc.gen(SlackGind,GEN_STATUS)>0),:);
    
    % if there is more than two generators, select the one with largest gen
    if size(gens,1) > 1
        [val ind] = max(gens(:,PMAX));
        slackgen = gens(ind,:);
    % or report error
    else if isempty(gens)
            disp('the number of buses in network:');
            disp(num2str(length(Cind)));
            disp('the slack bus in network:');
            disp(num2str(slack));
            error('no generators in this component!!!');
        else
            slackgen = gens;
            ind = 1;
        end
    end
    
    % check the power balance within component
    if (sum(old_mpc.bus(Cind,PD))+sum(old_mpc.bus(Cind,GS))-sum(old_mpc.gen(Gind,PG)))>tol
        disp(num2str(sum(old_mpc.bus(Cind,PD))+sum(old_mpc.bus(Cind,GS))-sum(old_mpc.gen(Gind,PG))));
        error('Power Not Balanced!');
    end
    
    % delete slackgen from Generate indices
    Gind(Gind==SlackGind(ind)) = [];
    
    if slackgen(PG) > 0
        % shed the power over the generation limit
        shed = slackgen(PG) - slackgen(PMAX);
        if shed > tol
            total_dmd = sum(old_mpc.bus(Cind,PD))+sum(old_mpc.bus(Cind,GS));
            rate = 1 - shed/total_dmd;
            new_mpc.bus(Cind,PD) = old_mpc.bus(Cind,PD)*rate;
        end
    else
        % slackgen(PG)<0 means dmd < gen
        total_dmd = sum(old_mpc.bus(Cind,PD));
        total_gen = sum(old_mpc.gen(Gind,PG));
               
        switch flag
            case 1
                % decrease generation
                rate = 1 - abs(slackgen(PG))/total_gen;
                new_mpc.gen(Gind,PG) = old_mpc.gen(Gind,PG)*rate;
            case 2
                % increase demand
                rate = 1 + abs(slackgen(PG))/total_dmd;
                new_mpc.bus(Cind,PD) = new_mpc.bus(Cind,PD)*rate;
        end
    end
end




