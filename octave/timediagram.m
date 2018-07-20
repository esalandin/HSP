function timediagram(vars, numJobs, type=0)    global numHoists;  numSteps= num_steps();  max_x= max(x_step(1:numSteps+1));    period= vars(index_var("period"));    % plot movimento carri  for h=1:numHoists    i_t=1;    td=[];    tds=[];    for job=-1:numJobs      for step=0:numSteps        if (h==vars(index_var("hoist_r", step)))          td(i_t, 1)= rem(vars(index_var("removal", step)), period) + job*period;          td(i_t, 2)= x_step(step);          i_t=i_t+1;          td(i_t, 1)= rem(vars(index_var("entry", step+1)), period)+ job*period;          td(i_t, 2)= x_step(step+1);          i_t=i_t+1;        endif      endfor    endfor    if (length(td)>0)      tds= sortrows(td);      legend_text=sprintf("hoist%02u", h);      plot(tds(:, 1), tds(:, 2), [";" legend_text ";"]), hold on;    endif  endfor  legend ("location", "northeastoutside");    % riga verticale sul periodo  for job=1:numJobs    plot([job*period job*period], [0 max_x],'k'), hold on;  endfor     % permanenza barre nelle vasche   for step=1:numSteps    text(0, x_step(step), num2str(step));    tentry= vars(index_var("entry", step));    tremoval= vars(index_var("removal", step));    for job=-numJobs:numJobs      plot([tentry+job*period tremoval+job*period], [x_step(step) x_step(step)], 'r:'); hold on;      plot([tentry+job*period], [x_step(step)], 'rv'); hold on;      plot([tremoval+job*period], [x_step(step)], 'r^'); hold on;    endfor  endfor  for job=-numJobs:numJobs    tremoval0= vars(index_var("removal", 0));    plot([tremoval0+job*period], [0], 'r^'); hold on;    tentryScarico= vars(index_var("entry", numSteps+1));    plot([tentryScarico+job*period], [x_step(numSteps+1)], 'rv'); hold on;  endfor    if (type==0)    xlim([0 period*numJobs]);  else    xlim([0 period]);  endif  ylim([0 max_x]);  endfunction