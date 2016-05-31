#include <vector>
#include <cryptominisat4/cryptominisat.h>
using std::vector;
using namespace CMSat;

#include <stdio.h>

typedef vector<Lit> *vec;

extern "C" {

  extern void bind(void);

  extern vec vec_create(void);
  extern void vec_destroy(vec );
  extern void vec_clear(vec v);
  extern void vec_push_back(vec v, int l, bool s);

  extern SATSolver *create(int verbose, long confl_limit, int num_threads);
  extern void destroy(SATSolver *s);
  extern void add_clause(SATSolver *s, vec c);
  extern void new_vars(SATSolver *s, int n);
  extern void new_var(SATSolver *s);
  extern int solve(SATSolver *s);
  extern int solve_with_assumptions(SATSolver *s, vec assump);
  extern int get_model(SATSolver *s, int i);
}

void bind(void) { }

vec vec_create(void) { return new vector<Lit>(); }
void vec_destroy(vec v) { delete v; }
void vec_clear(vec v) { v->clear(); }
void vec_push_back(vec v, int l, bool s) { v->push_back(Lit(l,s)); }

SATSolver *create(
    int verbose,
    long confl_limit,
    int num_threads) {

    SATSolver *cmsat = new SATSolver;
    if (NULL != cmsat) {
      cmsat->set_max_confl(confl_limit);
      cmsat->set_verbosity(verbose);
      cmsat->set_num_threads(num_threads);
    }

    return cmsat;
}

void destroy(SATSolver *s) { delete s; }

void add_clause(SATSolver *s, vec c) { s->add_clause(*c); }

void new_vars(SATSolver *s, int n) { s->new_vars(n); }

void new_var(SATSolver *s) { s->new_var(); }

int int_of_lbool(lbool b) {
  return 
    b == l_True  ? 0 :
    b == l_False ? 1 :
    b == l_Undef ? 2 :
                   3; // error - not expected to happen
}

int solve(SATSolver *s) { 
  return int_of_lbool(s->solve());
}

int solve_with_assumptions(SATSolver *s, vec assump) {
  return int_of_lbool(s->solve(assump));
}

int get_model(SATSolver *s, int i) {
  return int_of_lbool(s->get_model()[i]);
}

