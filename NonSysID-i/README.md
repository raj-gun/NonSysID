## NonSysID-i: Input-only model identification

NonSysID-i is a dedicated variant of NonSysID for identifying linear and
nonlinear input-only models. Its candidate regressors are constructed from
lagged inputs and their nonlinear combinations, without lagged output terms.

Use `NonSysID_i.m` as the main entry point.

### Appropriate applications

NonSysID-i is suitable when:

- the system output is to be represented solely as a function of present or
  lagged inputs;
- output-feedback regressors are undesirable;
- an input-only nonlinear mapping with dynamic input memory is required; or
- prediction without recursive dependence on previously predicted outputs is
  preferred.
