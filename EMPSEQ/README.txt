This folder contains the following files:

- EMPSEQ.m
  MATLAB function that carries out the Expectation-Maximization Pattern SEQuence (EM-PSEQ) method.

- EMPSEQ_simulConfMat.m
  Function that simulates a confusion matrix.

- EMPSEQ_simulPattSeq.m
  Function that simulates a PSEQ.

- EMPSEQ_Sim_Params.mat
  Contains 3 variables required to generate simulated data:
  (1) betamix_params -> beta parameters for the PDF of the diagonal elements of a scorer's confusion matrix,
  (2) ConfMat -> average confusion matrix from 3 human scorers,
  (3) refpatt -> pooled reference patterns from the analysis of 3 human scorers.

For a description of EM-PSEQ and additional information please refer to:
C. A. Robles-Rubio, K. A. Brown, R. E. Kearney, "Optimal Classification of Respiratory Patterns from Manual Analyses Using Expectation-Maximization," Journal of Biomedical and Health Informatics, In Press, 2017.