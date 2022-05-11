clear all;
close all;
time_log(1)=time;
format short g;

global ricetta;
init_ricetta;
global numJobs;
numJobs=5;
global numHoists;
numHoists=1;

margin=10;

% lin0
% Entry[0]= 0, Removal[0]= 0
RC=zeros(1, index_var("num"));
RC(index_var("entry", 0))=1;
vb=0;
A(1,:)=RC;
b(1)=vb;
ctype="S";

RC=zeros(1, index_var("num"));
RC(index_var("removal", 0))=1;
vb=0;
A= [A; RC];
b= [b; vb];
ctype= [ctype "S"];

% Ultimo Entry == Ultimo Removal
RC=zeros(1, index_var("num"));
RC(index_var("entry", num_steps()+1))= 1;
RC(index_var("removal", num_steps()+1))= -1;
vb=0;
A= [A; RC];
b= [b; vb];
ctype= [ctype "S"];

% lin1
% tra la estrazione da una posizione e l'inserimento nella successiva posizione deve esserci il tempo di sollevamento, gocciolamento, traslazione, abbassamento.
for s=1:num_steps()+1
  RC=zeros(1, index_var("num"));
  RC(index_var("entry", s))= 1;
  RC(index_var("removal", s-1))= -1;
  vb= hoist_move_t(s-1, s, "full");
  A= [A; RC];
  b= [b; vb];
  ctype= [ctype "S"];
endfor

% lin2
% tempo di permanenza
for s=1:num_steps()
  RC=zeros(1, index_var("num"));
  RC(index_var("removal", s))= 1;
  RC(index_var("entry", s))= -1;
  vb= ricetta(s, 1); % min
  A= [A; RC];
  b= [b; vb];
  ctype= [ctype "L"];

  RC=zeros(1, index_var("num"));
  RC(index_var("removal", s))= -1;
  RC(index_var("entry", s))= 1;
  vb= -ricetta(s, 2); % max
  A= [A; RC];
  b= [b; vb];
  ctype= [ctype "L"];
endfor

% lin3
RC=zeros(1, index_var("num"));
RC(index_var("period"))= numJobs;
RC(index_var("entry", num_steps()+1))= -1;
vb= hoist_move_t(num_steps()+1, 0, "empty");
A= [A; RC];
b= [b; vb];
ctype= [ctype "L"];

% lin4
% occupazione vasca (capacita')
for s=1:num_steps()
  RC=zeros(1, index_var("num"));
  RC(index_var("period"))= ricetta(s, 5); % capacity
  RC(index_var("entry", s))= 1;
  RC(index_var("removal", s))= -1;
  vb= margin;
  A= [A; RC];
  b= [b; vb];
  ctype= [ctype "L"];
endfor

% no overlap; disjunctive linearizzato
M= 10000;
for s1=0:num_steps()-1
  for s2=s1+1:num_steps()
    % carri diversi
    RC=zeros(1, index_var("num"));
    if (x_step(s2) >= x_step(s1))
      RC(index_var("hoist_r", s2))= 1;
      RC(index_var("hoist_r", s1))= -1;
    else
      RC(index_var("hoist_r", s2))= -1;
      RC(index_var("hoist_r", s1))= 1;
	endif
    RC(index_var("disj_diffhoist", s1, s2))= -M;
    vb= 1-M;
    A= [A; RC];
    b= [b; vb];
    ctype= [ctype "L"];

    for k=1:numJobs
      RC=zeros(1, index_var("num"));
      RC(index_var("disj_diffhoist", s1, s2))= 1;
      RC(index_var("disj_order", s1, s2, k-1))= 1;
      RC(index_var("disj_order", s1, s2, k-1)+1)= 1;
      vb= 1;
      A= [A; RC];
      b= [b; vb];
      ctype= [ctype "S"];

      RC=zeros(1, index_var("num"));
      RC(index_var("entry", s1+1))= 1;
      RC(index_var("period"))= k;
      RC(index_var("disj_order", s1, s2, k-1))= M;
      RC(index_var("removal", s2))= -1;
      vb= M-hoist_move_t(s1+1, s2, "empty");
      A= [A; RC];
      b= [b; vb];
      ctype= [ctype "U"];

      RC=zeros(1, index_var("num"));
      RC(index_var("entry", s2+1))= 1;
      RC(index_var("period"))= -k;
      RC(index_var("disj_order", s1, s2, k-1)+1)= M;
      RC(index_var("removal", s1))= -1;
      vb= M-hoist_move_t(s2+1, s1, "empty");
      A= [A; RC];
      b= [b; vb];
      ctype= [ctype "U"];

    endfor
  endfor
endfor

% compilazione di hoist_e
for s=0:num_steps()
  RC=zeros(1, index_var("num"));
  RC(index_var("hoist_r", s))= 1;
  RC(index_var("hoist_e", s+1))= -1;
  vb= 0;
  A= [A; RC];
  b= [b; vb];
  ctype= [ctype "S"];
endfor

% inizializzazione di hoist_e sul carico e hoist_r sullo scarico (solo per motivi estetici)
RC=zeros(1, index_var("num"));
RC(index_var("hoist_r", 0))= 1;
RC(index_var("hoist_e", 0))= -1;
vb= 0;
A= [A; RC];
b= [b; vb];
ctype= [ctype "S"];

RC=zeros(1, index_var("num"));
RC(index_var("hoist_r", num_steps()+1))= 1;
RC(index_var("hoist_e", num_steps()+1))= -1;
vb= 0;
A= [A; RC];
b= [b; vb];
ctype= [ctype "S"];

collision="fixed";
% hoist partition
if (strcmp(collision, "partition"))
  for s1=0:num_steps()-1
    for s2=s1+1:num_steps()
      RC=zeros(1, index_var("num"));
      if (x_step(s2)>=x_step(s1))
        RC(index_var("hoist_r", s2))= 1;
        RC(index_var("hoist_r", s1))= -1;
      else
        RC(index_var("hoist_r", s2))= -1;
        RC(index_var("hoist_r", s1))= 1;
      endif
      vb= 0;
      A= [A; RC];
      b= [b; vb];
      ctype= [ctype "L"];
    endfor
  endfor
elseif (strcmp(collision, "fixed"))
  for s=0:num_steps()
    if (hoist_r_step(s)>0)
      RC=zeros(1, index_var("num"));
      RC(index_var("hoist_r", s))= 1;
      vb= hoist_r_step(s);
      A= [A; RC];
      b= [b; vb];
      ctype= [ctype "S"];
    endif
  endfor
else
  error("collision");
endif

% end of constraints

vartype(1:index_var("num"))= "-";

lb(index_var("period"))=0;
ub(index_var("period"))=Inf;
vartype(index_var("period"))= "C";

for s=0:num_steps()+1
  lb(index_var("entry", s))=0;
  ub(index_var("entry", s))=Inf;
  vartype(index_var("entry", s))= "C";
  lb(index_var("removal", s))=0;
  ub(index_var("removal", s))=Inf;
  vartype(index_var("removal", s))= "C";
  lb(index_var("hoist_r", s))=1;
  ub(index_var("hoist_r", s))=numHoists;
  vartype(index_var("hoist_r", s))= "I";
  lb(index_var("hoist_e", s))=1;
  ub(index_var("hoist_e", s))=numHoists;
  vartype(index_var("hoist_e", s))= "I";
endfor

lb(index_var("disj_base_0"):index_var("num"))=0;
ub(index_var("disj_base_0"):index_var("num"))=1;
vartype(index_var("disj_base_0"):index_var("num"))="I";

% ricerca
c= zeros(index_var("num"), 1); c(index_var("period"))= 1;
glpk_param.msglev= 3;
% glpk_param.tolobj= 1;

time_log(2)= time;
[x, fmin, errnum, glpk_extra] = glpk (c, A, b, lb, ub, ctype, vartype, 1, glpk_param);
time_log(3)= time;

if (errnum!=0)
  printf("glpk error %d;\n", errnum);
elseif (glpk_extra.status==4)
  printf("glpk: Problem has no feasible solution\n");
else
  if (overlap(x, numJobs, 2)>eps)
    printf("Error: overlap found!\n");
  endif
  show_sol(x,0);
  timediagram(x, numJobs, 1);
endif
time_log(4)=time; printf("t %.1f minuti\n", (time_log(4)-time_log(1))/60);
