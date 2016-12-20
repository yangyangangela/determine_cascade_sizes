function display_pf_results(results, inc_ratio,cas_step)
% report the OPF results an interdependency ratio: inc_ratio
% test_time, and cascade steps


global tt; %test time
switch results.success
    case 1
        disp('---------------------------');
        disp(strcat('Interdependency: ',num2str(inc_ratio)));
        disp(strcat('Cutofflinetest no.',num2str(tt)));
        disp(strcat('OPF NO. ',num2str(cas_step),' SUCCESS'));
        disp('---------------------------');
    otherwise
        disp('---------------------------');
        disp(strcat('Interdependency: ',num2str(inc_ratio)));
        disp(strcat('Cutofflinetest no.',num2str(tt)));
        disp(strcat('|OPF NO. ',num2str(cas_step),' FAIL   |'));
        disp('---------------------------');
        error('The OPF cannot get optimal solutions');
end

return;