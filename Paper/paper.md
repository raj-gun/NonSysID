---
title: 'NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models'
tags:
  - System Identification
  - NARX
  - NARMAX
  - Orthogonal Least Squares
  - Time-series
  - Nonlinear dynamics
authors:
  - name: Rajintha Gunawardena
    orcid: 0000-0003-1192-9125
    equal-contrib: true
    affiliation: 1
  - name: Zi-Qiang Lang
    equal-contrib: true
    affiliation: 2
  - name: Fei He
    corresponding: true
    orcid: 0000-0003-1192-9125
    equal-contrib: true
    affiliation: 1
affiliations:
 - name: Centre for Computational Science and Mathematical Modelling, Coventry University, Coventry CV1 5FB, UK
   index: 1
 - name: School of Electrical and Electronic Engineering, The University of Sheffield, Western Bank, Sheffield S10 2TN, UK
   index: 2
date: 26 November 2024
bibliography: paper.bib
---

# Summary
System identification involves constructing mathematical models of dynamic systems using input-output data, enabling analysis and prediction of system behaviour in both time and frequency domains. This approach can model the entire system or capture specific dynamics within it. For meaningful analysis, it is essential for the model to accurately reflect the underlying system's behaviour. This paper introduces NonSysId, an open-sourced MATLAB software package designed for nonlinear system identification, specifically focusing on NARMAX models. The software incorporates an advanced term selection methodology that prioritises on simulation (free-run) accuracy while preserving model parsimony. A key feature is the integration of iterative Orthogonal Forward Regression (iOFR) with Predicted Residual Sum of Squares (PRESS) statistic-based term selection, facilitating robust model generalisation without the need for a separate validation dataset. Furthermore, techniques for reducing computational overheads are implemented. These features make NonSysId particularly suitable for real-time applications such as structural health monitoring, fault diagnosis, and biomedical signal processing, where it is a challenge to capture the signals under consistent conditions, resulting in limited or no validation data.

# Statement of Need

System identification is a field at the intersection of control theory, dynamic systems theory and machine learning that seeks to derive mathematical models of dynamic linear or nonlinear systems based on experimental input-output data. 
Generally, system identification has two primary objectives [@ljung1998system;@billings2013a], (i) to accurately map the system's inputs and outputs, allowing for the prediction of new, unseen data, and (ii) to capture the underlying dynamics of the system within the model.

The dynamic models generated through system identification can be either discrete or continuous time models [@UNBEHAUEN1997]. This paper centers on widely-used discrete-time models, specifically nonlinear auto-regressive models with exogenous inputs (NARX), where the ARX model is a linear variant of the NARX framework. These input-output time-series models predict future outputs of a system based on its historical input and output instances. NARX models have been applied extensively to model and analyse complex systems in fields such as control, fault diagnosis, structural health monitoring and the modelling and analysis of physiological and biological systems [@Chiras2002;@WANG2024;@ZAINOL2022;@RITZBERGER2017;@Gao2023;@HE2016;@HE2021]. Moreover, it has been demonstrated that the NARX model has equivalence to a recurrent neural network (RNN) [@Sum1999]. Extending the NARX model to incorporate a noise model, we obtain the nonlinear auto-regressive moving average with exogenous inputs (NARMAX) model.  

Recently two open-sourced packages have been introduced, `SysIdentPy` [@Lacerda2020] for Python and the `narmax` package [@AYALA2020] for R. Both packages are well-developed and comprehensive. However, they are based on the original forward regression orthogonal least squares (OFR) algorithm, which has been noted to have several limitations, as discussed in [@Piroddi2003;@Mao1997]. These concerns primarily involve over-fitting and inaccurate long-horizon predictions, particularly when the input fails to sufficiently excite the actual system. Additionally, in some applications, acquiring extra data for cross-validation may be infeasible. As a result, developing parsimonious models that can generalise well to unseen data becomes crucial in such cases. This paper introduces the `NonSysId` package, which incorporates an enhanced model selection process to address these challenges.

In the context of (N)ARX models, system identification is employed to determine a specific functional relationship that maps past input instances (input-lagged terms),
%
\begin{equation}\label{eq:Ut_sysid}
    U = \Big\{ u(t-1)\ ,\ u(t-2)\ ,\ \cdots,\ u(t-n_b) \Big\},
\end{equation}
%
and past output instances (output-lagged terms),
%
\begin{equation}\label{eq:Yt_sysid}
    Y = \Big\{ y(t-1)\ ,\ y(t-2)\ ,\ \cdots,\ y(t-n_a) \Big\}, 
\end{equation}
%
to the present output instance in time $y(t)$. $t$ here refers to a time index (i.e. $t$\textsuperscript{th} sample). $n_a$ and $n_b$ are the maximum number of past output and input time instances considered and are related to the Lyapunov exponents of the actual system that is being modelled [@mendes1998a]. The functional mapping is described by the following equation:
%
\begin{equation}\label{eq:sys_id_func}
y(t) = f^{P}\bigl( Y, U \bigr) + \xi(t),
\end{equation}
%
where $y(t)$ and $u(t)$ refer to the output and input respectively, while $\xi(t)$ represents the error between the predicted output $f^{P}\bigl( Y, U \bigr)$ and the actual output $y(t)$ at time instance $t$. $\xi(t)$ will contain noise and unmodeled dynamics. $f^{P}( \ )$ is the functional mapping between the past inputs and outputs to the current output $y(t)$. This mapping can take the form of a polynomial, a neural network, or even a fuzzy logic-based model. Here, we focus on polynomial NARX models with a maximum polynomial degree $N_p \in \mathbb{Z}^{+}$. In this case, Eq. \eqref{eq:sys_id_func} can be expressed as
%
\begin{equation}\label{eq:sys_id_func_summation}
y(t) = \sum_{m=1}^{M} \theta_{m} \times \phi_{m}(t) + \xi(t),
\end{equation}
%
where $m = 1, \cdots, M$, $M$ being the total number of variables or model terms. $\theta_{m}$ are the model parameters or coefficients and $\phi_{m}(t)$ are the corresponding model terms or variables. $\phi_{m}(t)$ are $n$\textsuperscript{th}-order monomials of the polynomial NARX model $f^{P}( \ )$, where $n = 1, \cdots, N_p$ is the degree of the monomial. $\phi_{m}(t)$ is composed of past output and input time instances from $Y$ and $U$. An example of a polynomial NARX model can be
%
\begin{equation}\label{eq:narx_exmpl}
    y(t) = \theta_{1}y(t-1) + \theta_{2}u(t-2) + \theta_{3}y(t-2)^{2}u(t-1)^{3} + \xi(t).
\end{equation}
%
In this example, $\phi_{1}(t)=y(t-1)$ and $\phi_{2}(t)=u(t-2)$ have a degree of 1 and are the linear terms (1\textsuperscript{st} order monomials or linear monomials) of the model. $\phi_{3}(t) = y(t-2)^{2}u(t-1)^{3}$ is a nonlinear term with a degree of $5$ (5\textsuperscript{th} order monomial, more generally a nonlinear monomial). The NARX model given in Eq. \ref{eq:narx_exmpl} has a polynomial degree $N_p=5$ (highest degree of any monomial). Given that the total number of time samples available is $L$, where $t = 1, \cdots, L$, Eq. \ref{eq:sys_id_func_summation} can be represented in matrix form as
%
\begin{equation}\label{eq:sys_id_func_mat}
\mathbf{Y} = \mathbf{\Phi} \mathbf{\Theta} + \mathbf{\Xi},
\end{equation}
%
where $\mathbf{Y} = \left[ y(1), \cdots, y(L) \right]^T$ is the vector containing the output samples $y(t)$. $\mathbf{\Phi} = \left[ \bar{\phi}_{1}, \cdots, \bar{\phi}_{M} \right]$, where $\bar{\phi}_{m} = \left[ \phi_{m}(1), \cdots, \phi_{m}(L) \right]^T$ is the vector containing all time samples of the model term $\phi_{m}(t)$. $\mathbf{\Theta} = \left[ \theta_{1}, \cdots, \theta_{M}  \right]^T$  is the parameter vector and $\mathbf{\Xi} = \left[ \xi(1), \cdots, \xi(L) \right]$ is the vector containing all the error terms $\xi(t)$ (i.e. model residuals). In the NARMAX model structure, a moving-average (MA) component is added to the NARX (Eq. \eqref{eq:sys_id_func_summation}) by incorporating linear and nonlinear lagged error terms (e.g., $\xi(t-2)$, $\xi(t-1)\xi(t-3)$). This noise model accounts for unmodeled dynamics and coloured noise, effectively isolating noise from the deterministic system and thereby reducing model bias \cite[Chapter~3]{billings2013a}.

The primary challenge in learning a polynomial NARX model is to identify the polynomial structure of the model, i.e. selecting which terms from a set of candidate model terms (monomials), denoted as $\mathcal{D}$, should be included in the model. For instance, a potential set of candidate terms could be
%
\begin{equation}\label{eq:exmpl_D}
    \mathcal{D} = \Big\{ 
              y(t-1), y(t-2), u(t-1), u(t-2), 
              y(t-1)u(t-2), y(t-2)u(t-1)^{3}, 
              y(t-2)^{2}u(t-1), y(t-2)^{2}u(t-1)^{3}
        \Big\} ,
\end{equation}
%
from which a NARX model structure, such as that in Eq. \ref{eq:narx_exmpl}, can be identified. Once the model structure is identified, the next step is to estimate the model parameters. However, determining the appropriate linear and nonlinear terms to include in the model structure is critical to achieving parsimonious models. This is particularly important in the nonlinear cases \cite[Chapter~1]{billings2013a}, as the inclusion of  unnecessary model terms, can result in a model that erroneously captures dynamics that do not belong to the underlying system [@AGUIRRE1995;@mendes1998a}.

The Orthogonal Forward Regression (OFR) algorithm, also known as Forward Regression OLS (FROLS) [@chen1989b;@billings1987a}, is based on the Orthogonal Least Squares (OLS). When combined with an appropriate term selection criterion [@korenberg1988a;@WANG1996;@hong2003}, it efficiently selects model terms (regressors) in a forward, sequential manner. In this approach, model terms are added one at a time based on a selection criterion, facilitating the development of a parsimonious model. The OFR/FROLS algorithm evaluates the impact of each term on the output independently of the influence of other terms, achieved through  orthogonalization procedures. This evaluation relies on the chosen term selection criterion, allowing for the sequential inclusion of appropriate terms in the final model using a forward selection approach. The most commonly used and widely accepted model term selection criterion used in the OFR algorithm is the error reduction ratio (ERR). During the forward selection procedures, the ERR selects the term that maximises explained variance, thereby  maximise the goodness of fit. Over the years, many variants of the OFR have been proposed. However, concerns persist regarding the original OFR algorithm (OFR-ERR), which relies on the ERR for term selection [@Piroddi2003;@Mao1997}, for example,
\begin{enumerate}
    \item OFR-ERR may select redundant or incorrect model terms, especially in the presence of complex noise structures or certain input signals;
    %
    \item The model structures produced from OFR can be sensitive to the first term selected in the forward selection of model terms;
    %
    \item If the input does not persistently excite the system under consideration (i.e. it lacks the informativeness needed to effectively stimulate the system), the resulting model can be inappropriate. This can result in inaccuracies in long-horizon prediction and, in some cases, even unstable models during simulation (free-run or model-predicted output);
    %
    \item The ERR focuses solely on explained variance when selecting terms, which can lead to overfitting. 
\end{enumerate}

Beyond obtaining parsimonious models, the model should generalise well to unseen data (validation) that is not used during the learning/training process (i.e. model identification). This is referred to as obtaining a bias-variance trade-off, which can be achieved through an appropriate cross-validation strategy [@Little2017;@Stone1974}. However, in some applications, obtaining separate validation data is not feasible. This is particularly true in real-time system identification applications, such as structural health monitoring or fault diagnosis [@Gharehbaghi2022;@Vamsikrishna2024}. Another example arises in neuroscience, where the dynamics between brain regions are highly time-varying and can change within milliseconds. As a result, obtaining electrophysiological data that precisely captures such behaviour is often challenging, if not impossible [@Kunjan2021;@Seedat2024;@Chen2016;@Eichenbaum2021;@Lehnertz2021}. These challenges are critical when applying system identification to specific domains. The following section outlines the features in the `NonSysId` package, designed to address these issues.

# Features in `NonSysId`

The `NonSysId` package introduced in this paper implements an OFR-based system identification methodology designed to address the key issues mentioned in the latter part of the previous section. This is achieved by integrating and extending several OFR variants already available in the literature [@guo2015a;@WANG1996;@hong2003], along with a proposed simulation-based model selection procedure. 
A notable feature of `NonSysId` is the implementation of the iterative-OFR (iFRO) variant [@guo2015a] of the OFR algorithm. Additionally, the PRESS-statistic-based term selection [@WANG1996;@hong2003] is integrated with the iOFR, complemented by simulation-based model selection. These enhancements enable robust term selection (compared to the ERR), built-in cross-validation, and the ability to produce models with long-horizon prediction capabilities and simulation stability [@AGUIRRE2010]. With these features, the `NonSysId` package makes system identification feasible for real-time applications, such as fault diagnosis in engineering or the analysis of electrophysiology activity in medical settings, where inputs may not be persistently exciting and separate datasets for validation may be unavailable. 
`NonSysId` is the only open-sourced package that directly addresses the limitations of the original OFR algorithm. For NARX models, where the candidate term set can be extensive and computationally demanding in the iFRO algorithm, `NonSysId` incorporates methods to reduce the candidate term set, significantly speeding up the forward selection process. Moreover, the package includes correlation-based residual analysis techniques for nonlinear model validation [@Billings1983].

## Iterative Orthogonal Forward Regression (iOFR)

## PRESS-Statistic Based Term Selection

## Computational Time Reduction





