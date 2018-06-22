function timediagram(vars, numJobs)  numSteps= num_steps();  period= vars(index_var("period"));    i_t=1;  for job=0:numJobs    for step=0:numSteps+1      td(i_t, 1)= rem(vars(index_var("entry", step)), period) + job*period;      td(i_t, 2)= step;      i_t=i_t+1;      td(i_t, 1)= rem(vars(index_var("removal", step)), period)+ job*period;      td(i_t, 2)= step;      i_t=i_t+1;    endfor  endfor    tds= sortrows(td);  plot(tds(:, 1), tds(:, 2)), hold on;  for job=1:numJobs    plot([job*period job*period], [0 numSteps+1],'k'), hold on;  endfor     for step=1:numSteps    tentry= vars(index_var("entry", step));    tremoval= vars(index_var("removal", step));    for job=-numJobs:numJobs      plot([tentry+job*period tremoval+job*period], [step step], 'r'); hold on;      plot([tentry+job*period], [step], 'rv'); hold on;      plot([tremoval+job*period], [step], 'r^'); hold on;    endfor  endfor  for job=-numJobs:numJobs    tremoval0= vars(index_var("removal", 0));    plot([tremoval0+job*period], [0], 'r^'); hold on;    tentryScarico= vars(index_var("entry", numSteps+1));    plot([tentryScarico+job*period], [numSteps+1], 'rv'); hold on;  endfor    xlim([0 period*numJobs]);  ylim([0 numSteps+1]);  endfunction