function show_sol(x, detail=0)
  global numJobs;
  global numHoists;

  printf("numero di cicli: %u;\n", numJobs);
  printf("numero di carri: %u;\n", numHoists);
  printf("Ciclo= %.1f secondi;\n", x(index_var("period")));
  poslist=(0:num_steps()+1)';
  disp('n pos; carro dep; tempo dep; carro prel; tempo prel; tempo perm')
  disp([poslist x(index_var("hoist_e", poslist)) x(index_var("entry", poslist)) x(index_var("hoist_r", poslist)) x(index_var("removal", poslist)) (x(index_var("removal", poslist)) - x(index_var("entry", poslist)))]);

  if (detail>=1)
    printf("disjunction\n");
    for s1=0:num_steps()-1
      for s2=s1+1:num_steps()
        printf( "%u-%u %u ", s1, s2, x(index_var("disj_diffhoist", s1, s2)));
        for k=0:numJobs-1
          printf("%u-%u ", x(index_var("disj_order", s1, s2, k)), x(index_var("disj_order", s1, s2, k)+1));
        endfor
        printf("\n");
      endfor
    endfor
  endif

  if (detail>=2)
    printf("disjunction 2\n");
    for s1=0:num_steps()-1
      for s2=s1+1:num_steps()
        if (x(index_var("disj_diffhoist", s1, s2))==0)
          printf("%u-%u: \n", s1, s2);
          for k=1:numJobs
            if (x(index_var("disj_order", s1, s2, k-1)))
              printf(" B1 %u-%u %u Rem[%u] > Ent[%u] + kP\n", s1+1, s2, k, s2, s1+1);
            endif
            if (x(index_var("disj_order", s1, s2, k-1)+1))
              printf(" B2 %u-%u %u Rem[%u] + kP> Ent[%u]\n", s1, s2+1, k, s1, s2+1);
            endif
          endfor
        endif
      endfor
    endfor
  endif

endfunction
