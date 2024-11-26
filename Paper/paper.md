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

\begin{equation}\label{eq:Ut_sysid}
    U = \Big\{ u(t-1)\ ,\ u(t-2)\ ,\ \cdots,\ u(t-n_b) \Big\},
\end{equation}

and past output instances (output-lagged terms),

\begin{equation}\label{eq:Yt_sysid}
    Y = \Big\{ y(t-1)\ ,\ y(t-2)\ ,\ \cdots,\ y(t-n_a) \Big\}, 
\end{equation}

to the present output instance in time $y(t)$. $t$ here refers to a time index (i.e. $t$\textsuperscript{th} sample). $n_a$ and $n_b$ are the maximum number of past output and input time instances considered and are related to the Lyapunov exponents of the actual system that is being modelled [@mendes1998a]. The functional mapping is described by the following equation:

\begin{equation}\label{eq:sys_id_func}
y(t) = f^{P}\bigl( Y, U \bigr) + \xi(t),
\end{equation}

where $y(t)$ and $u(t)$ refer to the output and input respectively, while $\xi(t)$ represents the error between the predicted output $f^{P}\bigl( Y, U \bigr)$ and the actual output $y(t)$ at time instance $t$. $\xi(t)$ will contain noise and unmodeled dynamics. $f^{P}( \ )$ is the functional mapping between the past inputs and outputs to the current output $y(t)$. This mapping can take the form of a polynomial, a neural network, or even a fuzzy logic-based model. Here, we focus on polynomial NARX models with a maximum polynomial degree $N_p \in \mathbb{Z}^{+}$. In this case, Eq. \eqref{eq:sys_id_func} can be expressed as

\begin{equation}\label{eq:sys_id_func_summation}
y(t) = \sum_{m=1}^{M} \theta_{m} \times \phi_{m}(t) + \xi(t),
\end{equation}

where $m = 1, \cdots, M$, $M$ being the total number of variables or model terms. $\theta_{m}$ are the model parameters or coefficients and $\phi_{m}(t)$ are the corresponding model terms or variables. $\phi_{m}(t)$ are $n$\textsuperscript{th}-order monomials of the polynomial NARX model $f^{P}( \ )$, where $n = 1, \cdots, N_p$ is the degree of the monomial. $\phi_{m}(t)$ is composed of past output and input time instances from $Y$ and $U$. An example of a polynomial NARX model can be

\begin{equation}\label{eq:narx_exmpl}
    y(t) = \theta_{1}y(t-1) + \theta_{2}u(t-2) + \theta_{3}y(t-2)^{2}u(t-1)^{3} + \xi(t).
\end{equation}

In this example, $\phi_{1}(t)=y(t-1)$ and $\phi_{2}(t)=u(t-2)$ have a degree of 1 and are the linear terms (1\textsuperscript{st} order monomials or linear monomials) of the model. $\phi_{3}(t) = y(t-2)^{2}u(t-1)^{3}$ is a nonlinear term with a degree of $5$ (5\textsuperscript{th} order monomial, more generally a nonlinear monomial). The NARX model given in Eq. \ref{eq:narx_exmpl} has a polynomial degree $N_p=5$ (highest degree of any monomial). Given that the total number of time samples available is $L$, where $t = 1, \cdots, L$, Eq. \ref{eq:sys_id_func_summation} can be represented in matrix form as

\begin{equation}\label{eq:sys_id_func_mat}
\mathbf{Y} = \mathbf{\Phi} \mathbf{\Theta} + \mathbf{\Xi},
\end{equation}

where $\mathbf{Y} = \left[ y(1), \cdots, y(L) \right]^T$ is the vector containing the output samples $y(t)$. $\mathbf{\Phi} = \left[ \bar{\phi}_{1}, \cdots, \bar{\phi}_{M} \right]$, where $\bar{\phi}_{m} = \left[ \phi_{m}(1), \cdots, \phi_{m}(L) \right]^T$ is the vector containing all time samples of the model term $\phi_{m}(t)$. $\mathbf{\Theta} = \left[ \theta_{1}, \cdots, \theta_{M}  \right]^T$  is the parameter vector and $\mathbf{\Xi} = \left[ \xi(1), \cdots, \xi(L) \right]$ is the vector containing all the error terms $\xi(t)$ (i.e. model residuals). In the NARMAX model structure, a moving-average (MA) component is added to the NARX (Eq. \eqref{eq:sys_id_func_summation}) by incorporating linear and nonlinear lagged error terms (e.g., $\xi(t-2)$, $\xi(t-1)\xi(t-3)$). This noise model accounts for unmodeled dynamics and coloured noise, effectively isolating noise from the deterministic system and thereby reducing model bias \cite[Chapter~3]{billings2013a}.

The primary challenge in learning a polynomial NARX model is to identify the polynomial structure of the model, i.e. selecting which terms from a set of candidate model terms (monomials), denoted as $\mathcal{D}$, should be included in the model. For instance, a potential set of candidate terms could be

\begin{equation}\label{eq:exmpl_D}
    \mathcal{D} = \Big\{ 
              y(t-1), y(t-2), u(t-1), u(t-2), 
              y(t-1)u(t-2), y(t-2)u(t-1)^{3}, 
              y(t-2)^{2}u(t-1), y(t-2)^{2}u(t-1)^{3}
        \Big\} ,
\end{equation}

from which a NARX model structure, such as that in Eq. \ref{eq:narx_exmpl}, can be identified. Once the model structure is identified, the next step is to estimate the model parameters. However, determining the appropriate linear and nonlinear terms to include in the model structure is critical to achieving parsimonious models. This is particularly important in the nonlinear cases \cite[Chapter~1]{billings2013a}, as the inclusion of  unnecessary model terms, can result in a model that erroneously captures dynamics that do not belong to the underlying system [@AGUIRRE1995;@mendes1998a}.

The Orthogonal Forward Regression (OFR) algorithm, also known as Forward Regression OLS (FROLS) [@chen1989b;@billings1987a}, is based on the Orthogonal Least Squares (OLS). When combined with an appropriate term selection criterion [@korenberg1988a;@WANG1996;@hong2003}, it efficiently selects model terms (regressors) in a forward, sequential manner. In this approach, model terms are added one at a time based on a selection criterion, facilitating the development of a parsimonious model. The OFR/FROLS algorithm evaluates the impact of each term on the output independently of the influence of other terms, achieved through  orthogonalization procedures. This evaluation relies on the chosen term selection criterion, allowing for the sequential inclusion of appropriate terms in the final model using a forward selection approach. The most commonly used and widely accepted model term selection criterion used in the OFR algorithm is the error reduction ratio (ERR). During the forward selection procedures, the ERR selects the term that maximises explained variance, thereby  maximise the goodness of fit. Over the years, many variants of the OFR have been proposed. However, concerns persist regarding the original OFR algorithm (OFR-ERR), which relies on the ERR for term selection [@Piroddi2003;@Mao1997}, for example,

1. OFR-ERR may select redundant or incorrect model terms, especially in the presence of complex noise structures or certain input signals.

2. The model structures produced from OFR can be sensitive to the first term selected in the forward selection of model terms.

3. If the input does not persistently excite the system under consideration (i.e., it lacks the informativeness needed to effectively stimulate the system), the resulting model can be inappropriate. This can result in inaccuracies in long-horizon prediction and, in some cases, even unstable models during simulation (free-run or model-predicted output).

4. The ERR focuses solely on explained variance when selecting terms, which can lead to overfitting.

Beyond obtaining parsimonious models, the model should generalise well to unseen data (validation) that is not used during the learning/training process (i.e. model identification). This is referred to as obtaining a bias-variance trade-off, which can be achieved through an appropriate cross-validation strategy [@Little2017;@Stone1974}. However, in some applications, obtaining separate validation data is not feasible. This is particularly true in real-time system identification applications, such as structural health monitoring or fault diagnosis [@Gharehbaghi2022;@Vamsikrishna2024}. Another example arises in neuroscience, where the dynamics between brain regions are highly time-varying and can change within milliseconds. As a result, obtaining electrophysiological data that precisely captures such behaviour is often challenging, if not impossible [@Kunjan2021;@Seedat2024;@Chen2016;@Eichenbaum2021;@Lehnertz2021}. These challenges are critical when applying system identification to specific domains. The following section outlines the features in the `NonSysId` package, designed to address these issues.

# Features in `NonSysId`

The `NonSysId` package introduced in this paper implements an OFR-based system identification methodology designed to address the key issues mentioned in the latter part of the previous section. This is achieved by integrating and extending several OFR variants already available in the literature [@guo2015a;@WANG1996;@hong2003], along with a proposed simulation-based model selection procedure. 
A notable feature of `NonSysId` is the implementation of the iterative-OFR (iFRO) variant [@guo2015a] of the OFR algorithm. Additionally, the PRESS-statistic-based term selection [@WANG1996;@hong2003] is integrated with the iOFR, complemented by simulation-based model selection. These enhancements enable robust term selection (compared to the ERR), built-in cross-validation, and the ability to produce models with long-horizon prediction capabilities and simulation stability [@AGUIRRE2010]. With these features, the `NonSysId` package makes system identification feasible for real-time applications, such as fault diagnosis in engineering or the analysis of electrophysiology activity in medical settings, where inputs may not be persistently exciting and separate datasets for validation may be unavailable. 
`NonSysId` is the only open-sourced package that directly addresses the limitations of the original OFR algorithm. For NARX models, where the candidate term set can be extensive and computationally demanding in the iFRO algorithm, `NonSysId` incorporates methods to reduce the candidate term set, significantly speeding up the forward selection process. Moreover, the package includes correlation-based residual analysis techniques for nonlinear model validation [@Billings1983].

## Iterative Orthogonal Forward Regression (iOFR)

To address the concerns associated with the original OFR, the iterative-OFR (iOFR) algorithm was introduced in [@guo2015a]. To the best of our knowledge, no open-source software implementing this variant currently exists. In the original OFR, the term selection is heavily influenced by the order of orthogonalization, which can often result in incorrect terms being selected in the early stages [@guo2015a;@Mao1997]. Additionally, the order in which terms are selected in the OFR determines the orthogonalization path, resulting in a tree structure of possible models [@guo2015a;@Mao1997]. Finding a globally optimal solution would require an exhaustive search through all orthogonalization paths - an infeasible task given the factorial  growth in paths ($k!$ paths for $k$ terms). The iOFR algorithm addresses this limitation by iteratively exploring multiple orthogonalization paths and re-selecting terms to approximate a globally optimal model without exhaustive search [@guo2015a]. This approach enables the recovery of correct terms that might have been overlooked in earlier iterations. As a result, the iOFR generates several candidate models for consideration. 

The iOFR procedures [@guo2015a] can be summarised as follows. Given an output vector $\mathbf{Y}$, a set of candidate terms $\mathcal{D}$ and a set of pre-select terms $\mathcal{P} \subseteq \mathcal{D}$, where $\mathcal{P} = \{ \phi_1 , \dots, \phi_p  \}$, 1) pre-select each term given in $\mathcal{P}$ as the first model term; 2) use OFR to search through $p$ orthogonalization paths resulting in a set of $p$ candidate models $\mathcal{M} = \{ m_1, \dots, m_p \}$; 3) from $\mathcal{M}$, select the best model $\overline{m}$ based on the one-step-ahead prediction error; and 4) update the set of pre-select terms $\mathcal{P}$ with the terms in $\overline{m}$. The process is repeated iteratively with the updated $\mathcal{P}$ to search through different orthogonalization paths.    

As shown in [@guo2015a], the iOFR can iteratively produce more globally optimal model structures. This is because optimal solutions are only found along orthogonalization paths that begin with a correct term [@guo2015a;@Mao1997] (candidate terms essential for accurately reconstructing dynamics of the original system [@mendes1998a;@AGUIRRE1994]). Although the best model $\overline{m}$ obtained in each iteration may be sub-optimal, it will include certain correct terms [@guo2015a]. Consequently, in subsequent iterations, $\mathcal{P}$ will contain fewer redundant model terms. This refinement ensures that, in the next iteration, a relatively greater proportion of the orthogonalization paths explored by the OFR will start from better initial terms, leading to a more robust set of models $\mathcal{M}$ [@guo2015a]. For the first iOFR iteration, the pre-select terms, $\mathcal{P}$, can be set to $\mathcal{P} = \mathcal{D}$. Since it is sufficient to focus on orthogonalization paths that begin with correct terms [@guo2015a], methods for selecting the initial set $\mathcal{P}$ will be discussed in later sections. This will make the iOFR converge faster towards an optimum while improving computational efficiency.

In the original iOFR algorithm [@guo2015a], model selection was based on the one-step-ahead prediction. The implementation of iOFR in the `NonSysId' extends this by incorporating simulation-based model selection ($\text{iOFR}_{S}$) to ensure simulation stability and improve long-horizon prediction accuracy. The procedures for $\text{iOFR}_{S}$ are as follows:

1. Pre-select each term given in $\mathcal{P}$ as the first model term and search through $p$ orthogonalization paths using OFR to produce a set of $p$ candidate models $\Tilde{\mathcal{M}} = \{ \Tilde{m}_1, \dots, \Tilde{m}_p \}$.

2. From $\Tilde{\mathcal{M}}$, determine the set of stable candidate models $\mathcal{M} = \{ m_1, \dots, m_{\overline{p}} \}$, where $\overline{p} \leq p$.

3. From $\mathcal{M}$, based on the simulation error, choose the best model $\overline{m}$.

4. Use the terms in $\overline{m}$ to form the new set of pre-selected terms $\mathcal{P}$.

5. Repeat steps 1–4 and iteratively search through different orthogonalization paths.

In step 2, each model $\Tilde{m}_i \in \Tilde{\mathcal{M}}$, $i=1,\dots,p$, is tested using two inputs: (i) a sequence of 0's, $u^{[0]}(t) = 0 \ \forall t$, and (ii) a sequence of 1's, $u^{[1]}(t) = 1 \ \forall t$. The corresponding simulated outputs, $\hat{y}^{[0]}(t)$ and $\hat{y}^{[1]}(t)$, must meet stability conditions for $\Tilde{m}_i$ to be included in $\mathcal{M}$. In this context, stability implies that the outputs remain bounded over time, i.e. stable around a mean without exhibiting exponential growth. Specifically, the responses ($j = 0 \ \text{or} \ 1$) should be around a mean, $\mathbb{E}[\hat{y}^{[j]}(t)] \in \mathbb{R}$, with a small variance, $\text{Var}(\hat{y}^{[j]}(t)) \leq \varepsilon$. Typically, $\varepsilon = 10^{-2}$. Specifically, for $u^{[0]}(t)$, $\mathbb{E}[\hat{y}^{[0]}(t)] = \beta$, where $\beta$ is the bias term (DC offset) in the model, with $\beta=0$ indicating the absence of a bias term. In step 3, the Bayesian Information Criterion (BIC) [@Schwarz1978;@Stoica2004] is used to select the optimal model $\overline{m}$ from $\mathcal{M}$. The BIC is calculated based on the simulated error variance (i.e. mean squared simulated error [@Piroddi2003}—MSSE) between the actual output and the model's simulated output. The $\text{iOFR}_{S}$ can be represented in functional form as $( \mathcal{M}, \overline{m} ) = \text{iOFR}_{S}( \mathcal{D}, \mathcal{P}, \mathbf{Y})$.

## PRESS-statistic-based term selection

The model must generalise effectively to unseen data during training, striking a balancing bias and variance. This can be achieved using robust cross-validation strategies. Ideally, an algorithm should optimise model generalisation without relying on a separate validation dataset. A PRESS-statistic-based [@Allen1974] term selection criterion with leave-one-out cross-validation was introduced into the OFR framework in [@WANG1996;@hong2003]. Leveraging the OLS method in OFR, the computation of the leave-one-out cross-validation errors is highly efficient [@WANG1996;@hong2003]. Integrating the PRESS-statistic-based criterion into the OFR algorithm enables the selection of regressors (model terms) that incrementally minimise the one-step ahead leave-one-out cross-validation error in a forward selection manner, effectively reducing overfitting to noise. This approach fully automates the model evaluation process, eliminating the need for additional validation data. Consequently, applying the PRESS-statistic-based term selection criterion within the $\text{iOFR}_{S}$ algorithm enhances the selection of more robust terms and improves the generalisation capabilities of the resulting models.

## $\text{iOFR}_{S}$ with reduced computational time

This section outlines the comprehensive procedures implemented in the `NonSysId` package for identifying (N)ARX models from system input-output data using $\text{iOFR}_{S}$ algorithm combined with PRESS-statistic-based term selection. Additionally, techniques for reducing computational time in $\text{iOFR}_{S}$ are discussed. These techniques focus on efficiently reducing the number of candidate terms, pre-select terms, or both.       

Let $\mathcal{D'}$ denote the set of candidate linear terms comprising past inputs $U$ and outputs $Y$ (as defined in Eq. \eqref{eq:Ut_sysid} and \eqref{eq:Yt_sysid}, respectively), such that $\mathcal{D'} = Y \cup U$. This set is used to identify or learn an ARX model. Similarly, let $\mathcal{D}''$ represent the set of candidate terms that includes both linear and nonlinear terms, enabling the identification of a NARX model. Typically, $\mathcal{D}''$ is constructed by expanding $\mathcal{D'}$ to include additional nonlinear terms (nonlinear monomials) generated through combinations of terms in $\mathcal{D}'$, such that $\mathcal{D}'' \supset \mathcal{D}'$. However, as the number of past inputs and outputs increases (i.e. number of terms in set $\mathcal{D'}$, $|\mathcal{D'}|$) and higher degrees of nonlinearity are considered, the number of candidate nonlinear terms, $|\mathcal{D}'' - \mathcal{D'}|$, can increase exponentially [@billings2013a]. This rapid growth significantly raises the computational time needed to build a NARX model using the iOFR or $\text{iOFR}_{S}$ algorithms. Therefore, reducing the candidate set $\mathcal{D}''$, $\mathcal{D}''_{R}$ ($\mathcal{D}''_{R} \subset \mathcal{D}''$), can significantly decrease the search space for model terms, thereby offering a computational advantage. Additionally, in the initial iteration of the iOFR algorithm, minimizing the presence of redundant terms in the pre-select set $\mathcal{P}$ (i.e. the initial set $\mathcal{P}$) can expedite convergence toward an optimum model [@guo2015a], which also applies to $\text{iOFR}_{S}$. This section will explore methods for obtaining a reduced $\mathcal{D}''$, i.e. $\mathcal{D}''_{R}$, and a more effective initial set $\mathcal{P}$. The techniques presented aim to streamline the search space and reduce the computational demands of $\text{iOFR}_S$.  

A technique for obtaining a reduced set of candidate model terms, $\mathcal{D}''_{R}$, was proposed in [@Wei2004]. This approach is based on the idea that if a lagged term significantly influences the output of a nonlinear system, it will also be significant in a linearised representation of the system. Accordingly, a linear ARX model is identified first, serving as a linearised model of the actual nonlinear system. The terms from this ARX model are then used to construct $\mathcal{D}''_{R}$. This method has been incorporated into the `NonSysId` package. Regarding the set $\mathcal{P}$, an initialisation method for the iOFR algorithm was proposed in [@guo2015a]. In this method, an overfitting NARX model, $\overline{m_{0}''}$, is first identified using the OFR. The terms from $\overline{m_{0}''}$ are then used to construct the initial set $\mathcal{P}$ for the first iteration of the iOFR. While $\overline{m_{0}''}$ may be sub-optimal, it is likely to include some correct terms. Consequently, using the terms of $\overline{m_{0}''}$ to form the initial set $\mathcal{P}$ ensures fewer redundant terms compared to directly setting $\mathcal{P} \subseteq \mathcal{D}$ [@guo2015a]. 

The `NonSysId` package incorporates both aforementioned methods to reduce the computational time of $\text{iOFR}_{S}$. Additionally, the `NonSysId` package implements two new methods, proposed in this paper, to further enhance computational efficiency (referred to as reducing computational time, RCT, methods). Algorithm \ref{alg:NonSysId} outlines the procedures of the complete system identification methodology, integrating $\text{iOFR}_{S}$ with these four RCT methods. A brief overview of each RCT method is provided below.

- **RCT Method 1**: This method, as proposed in [@Wei2004], seeks to obtain a reduced set of candidate model terms, enabling $\text{iOFR}_{S}$ to operate within a narrower search space defined by $\mathcal{D}''_{R} \subset \mathcal{D}''$.

- **RCT Method 2**: This method, as proposed in [@guo2015a], identifies an appropriate initial set of pre-select terms, $\mathcal{P}$, for the first iteration of the iOFR algorithm. By ensuring that $\mathcal{P} \subset \mathcal{D}''$ (containing fewer redundant terms compared to $\mathcal{P} \subseteq \mathcal{D}$), the first iteration of iOFR/$\text{iOFR}_{S}$ involves fewer orthogonalization paths originating from redundant terms. This accelerates convergence towards an optimal model [@guo2015a].

- **RCT Method 3**: This method combines RCT methods 1 and 2, such that $\mathcal{P} \subset \mathcal{D}''_{R}$ and $\text{iOFR}_{S}$ searches through an appropriately reduced space defined by $\mathcal{D}''_{R}$. As a result, this approach enables faster convergence of $\text{iOFR}_{S}$ to an optimal model compared to any other RCT method.

- **RCT Method 4**: This method combines RCT methods 1 and 2, such that $\mathcal{P} \subset \mathcal{D}''_{R}$. However, $\text{iOFR}_{S}$ searches through the full space $\mathcal{D}''$ instead of $\mathcal{D}''_{R}$. Therefore, this technique converges the $\text{iOFR}_{S}$ faster to an optimal model compared to RCT method 2.

`\input{alg1}`

The RCT methods aim to accelerate the convergence of $\text{iOFR}_{S}$ and reduce the time required to obtain a model. Using $\mathcal{D}''_{R}$ reduces the computational time for the OFR algorithm within $\text{iOFR}_{S}$, by shortening the time needed to follow a given orthogonalization path. Additionally, fewer redundant terms in $\mathcal{P}$ lead to faster convergence of $\text{iOFR}_{S}$ and contribute to reducing time by minimizing the number of orthogonalization paths [@guo2015a]. Therefore, the most effective RCT method is 3, followed by methods 1,4 and 2. However, when reducing the search space (determining $\mathcal{D}''_{R}$), RCT methods 1 and 3 may miss some correct terms, potentially resulting in convergence to a sub-optimal model. This outcome depends on the level of white and coloured noise in the input-output data, as well as the complexity of the original system. It should be noted that RCT methods introduce additional procedures. Therefore, if $\mathcal{D}''$ is small enough, running $\text{iOFR}_{S}$ without any RCT methods may be faster. The figure below summarises Algorithm \ref{alg:NonSysId} in a flowchart. The following section will provide examples from the `NonSysId` package. 

![This flowchart summarises the procedures for identifying a (N)ARX model using $\text{iOFR}_{S}$ as described in Algorithm \ref{alg:NonSysId}. The region shaded in brown represents the ARX model identification process, while the blue-shaded region highlights the NARX procedures.\label{fig:flowcharts}](Figures/iOFR_S_RCT.svg){ width=0.85 }

NARX models can be analysed in the frequency domain using Nonlinear Output Frequency Response Functions (NOFRFs) [@Lang2005], which extend classical frequency response analysis to nonlinear systems \cite[Chapter~6]{billings2013a}. The NOFRF concept is an essential tool for system identification, describing how input frequencies interact nonlinearly to generate output frequencies that are harmonics and intermodulation effects. This facilitates a detailed understanding of how nonlinearities affect input-output dynamics [@Lang2005;@BAYMA2018]. NOFRFs can be evaluated using various methods [@Gunawardena2018;@ZHU2022], providing enhanced insights into the frequency-domain behaviour of complex nonlinear systems. Consequently, NOFRFs enhance the utility of NARX models by offering a comprehensive framework for analysing and interpreting nonlinear system [@Zhu2021]. 





