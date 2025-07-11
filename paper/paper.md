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
    affiliation: 1
  - name: Zi-Qiang Lang
    affiliation: 2
  - name: Fei He
    orcid: 0000-0003-1192-9125
    affiliation: 1
affiliations:
  - index: 1
    name: Centre for Computational Science and Mathematical Modelling, Coventry University, Coventry CV1 5FB, UK
  - index: 2
    name: School of Electrical and Electronic Engineering, The University of Sheffield, Western Bank, Sheffield S10 2TN, UK
date: 26 November 2024
bibliography: paper.bib
---

# Summary
System identification involves constructing mathematical models of dynamic systems using input-output data, enabling analysis and prediction of system behaviour in both time and frequency domains. This approach can model the entire system or/and capture specific dynamics within it. For meaningful analysis, it is essential for the model to accurately reflect the underlying system's behaviour. This paper introduces NonSysId, an open-sourced MATLAB software package designed for nonlinear system identification, specifically focusing on NARMAX models. The software incorporates an advanced term selection methodology that prioritises simulation (free-run) accuracy while preserving model parsimony. A key feature is the integration of iterative Orthogonal Forward Regression (iOFR) with Predicted Residual Sum of Squares (PRESS) statistic-based term selection, facilitating robust model generalisation without the need for a separate validation dataset. Furthermore, techniques for reducing computational overheads are implemented. These features make `NonSysId` particularly suitable for real-time applications such as structural health monitoring, fault diagnosis, and biomedical signal processing, where it is a challenge to capture the signals under consistent conditions, resulting in limited or no validation data.

# Statement of Need

System identification is at the intersection of control theory, dynamic systems theory and machine learning, which aims to derive mathematical models (can be continuous-time or discrete-time models [@UNBEHAUEN1997]) of dynamic linear or nonlinear systems based on experimental input-output data. Its objectives are (i) accurate input–output mapping for prediction and (ii) to capture the underlying dynamics of the system within the model [@ljung1998system; @billings2013a]. This paper focuses on the widely used discrete-time nonlinear auto-regressive with exogenous input (NARX) models, with ARX as the linear special case. These are input-output time-series models that predict a system’s future outputs based on its past inputs and outputs. Therefore, system identification determines a functional mapping from past input/output terms (lagged terms) to the current output $y(t)$, where $t$ denotes the time index. This mapping may be polynomial, a neural network, or even a fuzzy logic-based model. We focus on polynomial NARX models with maximum degree $N_p \in \mathbb{Z}^{+}$. For example:

\begin{equation}\label{eq:narx_exmpl}
    y(t) = \theta_{1}y(t-1) + \theta_{2}u(t-2) + \theta_{3}y(t-2)^{2}u(t-1)^{3} + \xi(t).
\end{equation}

Here, $\phi_{1}(t)=y(t-1)$ and $\phi_{2}(t)=u(t-2)$ are linear terms (degree $1$ monomials or linear monomials), while$\phi_{3}(t) = y(t-2)^{2}u(t-1)^{3}$ is nonlinear term (degree $5$ monomial, more generally a nonlinear monomial). The NARX model given in \autoref{eq:narx_exmpl} has a polynomial degree $N_p=5$ (highest degree of any monomial). NARX models are widely used in fields such as control, condition monitoring, advanced manufacturing, and the modelling and analysis of physiological and biological systems [@Chiras2002;@WANG2024;@ZAINOL2022;@RITZBERGER2017;@Gao2023;@HE2016;@HE2021;@LIU2024]. Notably, they are equivalent to RNNs [@Sum1999]. Extending the NARX model with a noise model yields the nonlinear auto-regressive moving average with exogenous inputs (NARMAX) model.

The key challenge in learning a polynomial NARX model is to identify an appropriate polynomial structure, i.e. from a set of candidate terms (monomials), selecting which terms to include. Parsimony is essential, especially in nonlinear cases (Chapter 1, [@billings2013a]), because superfluous terms can lead to spurious dynamics [@AGUIRRE1995;@mendes1998a]. The Orthogonal Forward Regression (OFR) algorithm, also known as Forward Regression OLS (FROLS) [@chen1989b; @billings1987a], based on Orthogonal Least Squares (OLS), efficiently selects regressors via forward selection. Through orthogonalization, according to a term selection criterion [@korenberg1988a; @WANG1996; @hong2003], the OFR can evaluate the individual contribution of each term to the output, enabling sequential inclusion of significant terms--forward selection. The most widely used term selection criterion for the OFR is the error reduction ratio (ERR), which chooses terms that maximise the explained variance during forward selection, thus incrementally improving model fit.  Numerous variants of OFR have since been proposed. Recently, two open-sourced packages for system identification have been introduced: `SysIdentPy` [@Lacerda2020] for Python and the `narmax` package [@AYALA2020] for R. Both packages are well-developed and comprehensive. However, they are based on the original FROLS/OFR algorithm. Concerns persist regarding the original OFR algorithm (OFR-ERR), which relies on the ERR for term selection [@Piroddi2003;@Mao1997], for example,

1. OFR-ERR may select redundant or incorrect model terms, especially in the presence of complex noise structures or certain input signals.

2. The model structures produced from OFR can be sensitive to the first term selected in the forward selection of model terms. The term selection is heavily influenced by the order of orthogonalization, which can often result in incorrect terms being selected in the early stages.

3. If the input does not persistently excite the system under consideration (i.e., it lacks the informativeness needed to effectively stimulate the system), the resulting model can be inappropriate. This can result in inaccuracies in long-horizon prediction and, in some cases, even unstable models during simulation (free-run or model-predicted output).

4. The ERR focuses solely on explained variance when selecting terms, which can lead to overfitting.

Beyond obtaining parsimony, models must generalise well to unseen data--validation data not used during training (model identification). This reflects the bias–variance trade-off, often addressed through suitable cross-validation strategies [@Little2017; @Stone1974]. However, in some applications, such as structural health monitoring or fault diagnosis, obtaining separate validation data may be impractical [@Gharehbaghi2022; @Vamsikrishna2024]. Similarly, in neuroscience, rapidly changing complex dynamics between brain regions can occur within milliseconds, making it difficult to obtain electrophysiological data that precisely capture the same behaviour for validation purposes [@Kunjan2021; @Seedat2024; @Chen2016; @Eichenbaum2021; @Lehnertz2021]. These challenges are critical when applying system identification to specific domains. The following section outlines the features in the `NonSysId` package, designed to address these issues.

# Features in `NonSysId`

The `NonSysId` package introduced in this paper implements an OFR-based system identification methodology designed to address the key issues mentioned in the latter part of the previous section. This is achieved by integrating and extending several OFR variants already available in the literature [@guo2015a;@WANG1996;@hong2003], along with a proposed simulation-based model selection procedure. 

A notable feature of `NonSysId` is the implementation of the iterative OFR (iFRO) variant [@guo2015a] of the OFR algorithm. Additionally, the PRESS-statistic-based term selection [@WANG1996;@hong2003] is integrated with the iOFR, complemented by simulation-based model selection. To address the concerns associated with the original OFR, the iOFR algorithm was introduced in [@guo2015a] and to the best of our knowledge, no open-source software implementing this variant currently exists. The iOFR algorithm iteratively explores multiple orthogonalization paths and re-selects terms to approximate a globally optimal model without exhaustive search [@guo2015a]. Consequently, it can iteratively produce more globally optimal model structures [@guo2015a]. This approach enables the recovery of correct terms (candidate terms essential for accurately reconstructing dynamics of the original system [@mendes1998a;@AGUIRRE1994]) that might have been overlooked in earlier iterations. As a result, the iOFR generates several candidate models for consideration. In the original iOFR algorithm [@guo2015a], model selection was based on the one-step-ahead prediction. The implementation of iOFR in the `NonSysId' extends this by incorporating simulation-based model selection ($\text{iOFR}_{S}$) to ensure simulation stability and improve long-horizon prediction accuracy. To ensure good generalisation and obtain a good bias-variance compromise, a PRESS-statistic-based [@Allen1974] term selection with leave-one-out cross-validation was integrated into OFR in [@WANG1996; @hong2003]. Leveraging the orthogonalization procedures in OFR, one-step ahead leave-one-out errors can be computed efficiently, allowing forward selection of terms that minimise the cross-validation error without extra validation data. Incorporating this into $\text{iOFR}_{S}$ improves the robustness and generalisation of the selected model terms. 

The above-mentioned enhancements enable robust term selection (compared to the ERR), built-in cross-validation, and the ability to produce models with long-horizon prediction capabilities and simulation stability [@AGUIRRE2010]. With these features, the `NonSysId` package makes system identification feasible for real-time applications, such as fault diagnosis in engineering or the analysis of electrophysiology activity in medical settings, where inputs may not be persistently exciting and separate datasets for validation may be unavailable. `NonSysId` is the only open-sourced package that implements previously proposed solutions to address the limitations of the original OFR algorithm directly. For NARX models, where the candidate term set can be extensive and computationally demanding in the iFRO algorithm, `NonSysId` incorporates methods to reduce the candidate term set, significantly speeding up the forward selection process. Also, the package includes correlation-based residual analysis techniques for nonlinear model validation [@Billings1983].

In the original iOFR algorithm [@guo2015a], model selection was based on the one-step-ahead prediction. The implementation of iOFR in the `NonSysId' extends this by incorporating simulation-based model selection ($\text{iOFR}_{S}$) to ensure simulation stability and improve long-horizon prediction accuracy. There are two simple tests done to ensure simulation stability (bounded-input bounded-output). Using a pre-select term list $\mathcal{P}$, the iFRO algorithm explores several orthogonalization paths, each producing a candidate model. These models are tested for stability using two constant inputs: $u^{[0]}(t) = 0 \ \forall t$ and $u^{[1]}(t) = 1 \ \forall t$. The corresponding simulated outputs $\hat{y}^{[0]}(t)$ and $\hat{y}^{[1]}(t)$ must remain bounded with a small variance, i.e., $\mathbb{E}[\hat{y}^{[j]}(t)] \in \mathbb{R}$ and $\text{Var}(\hat{y}^{[j]}(t)) \leq \varepsilon$ ($j = 0 \text{or} 1$), typically with $\varepsilon = 10^{-2}$. For $u^{[0]}(t)$, the mean equals the model’s bias (DC-offset) term $\beta$. Afterwards, the Bayesian Information Criterion (BIC) [@Schwarz1978; @Stoica2004], based on the mean squared simulated error (MSSE) [@Piroddi2003], selects the best model $\overline{m}$ from the previously determined set of stable models. $\mathcal{P}$ is updated with the term of $\overline{m}$, and the next iteration begins.

Let $\mathcal{D'}$ be the set of candidate linear terms from past outputs and inputs for ARX model identification. For NARX models, the candidate set $\mathcal{D}''$ includes both linear and nonlinear terms, so $\mathcal{D}'' \supset \mathcal{D'}$. As the polynomial nonlinearity considered increases, $|\mathcal{D}''|$ can grow exponentially. On top of this, if the number of past outputs and inputs considered also increases, $|\mathcal{D}''|$ explodes [@billings2013a], increasing computational cost for iOFR/$\text{iOFR}_S$. Appropriately reducing this set to $\mathcal{D}''_R \subset \mathcal{D}''$ can reduce complexity. Likewise, minimizing redundant terms in the initial pre-select set $\mathcal{P}$ ($\mathcal{P}$ at the first iteration) can speed up convergence toward an optimum model [@guo2015a]. The `NonSysId` package implements four strategies to effectively reduce $\mathcal{D}''$ ($\mathcal{D}''_R$) and optimize the initial set $\mathcal{P}$ to improve $\text{iOFR}_S$ efficiency.

A strategy to obtain a set $\mathcal{D}''_{R}$ was proposed in [@Wei2004], based on the idea that important lagged terms in a nonlinear system will also appear in its linearised ARX model. This is implemented in the `NonSysId` package. For the initial $\mathcal{P}$, [@guo2015a] suggests identifying an overfitted NARX model $\overline{m_{0}''}$ using OFR. The terms from $\overline{m_{0}''}$ are then used to form $\mathcal{P}$ for the first iOFR/$\text{iOFR}_S$ iteration. Although $\overline{m_{0}''}$ may not be optimal, it likely contains some correct terms and results in fewer redundant terms than choosing $\mathcal{P} \subseteq \mathcal{D}''$ directly. The `NonSysId` package incorporates both aforementioned strategies to reduce the computational time of $\text{iOFR}_{S}$. Additionally, the `NonSysId` package implements two new strategies, proposed in this paper, to further enhance computational efficiency (referred to as strategies reducing computational time, RCT). A brief overview of each RCT strategy is provided below.

- **RCT Method 1**: This method, as proposed in [@Wei2004], seeks to obtain a reduced set of candidate model terms, enabling $\text{iOFR}_{S}$ to operate within a narrower search space defined by $\mathcal{D}''_{R} \subset \mathcal{D}''$.

- **RCT Method 2**: This method, as proposed in [@guo2015a], identifies an appropriate initial set of pre-select terms, $\mathcal{P}$, for the first iteration of the iOFR algorithm. By ensuring that $\mathcal{P} \subset \mathcal{D}''$ (containing fewer redundant terms compared to $\mathcal{P} \subseteq \mathcal{D}$), the first iteration of iOFR/$\text{iOFR}_{S}$ involves fewer orthogonalization paths originating from redundant terms. This accelerates convergence towards an optimal model [@guo2015a].

- **RCT Method 3**: This method combines RCT methods 1 and 2, such that $\mathcal{P} \subset \mathcal{D}''_{R}$ and $\text{iOFR}_{S}$ searches through an appropriately reduced space defined by $\mathcal{D}''_{R}$. As a result, this approach enables faster convergence of $\text{iOFR}_{S}$ to an optimal model compared to any other RCT method.

- **RCT Method 4**: This method combines RCT methods 1 and 2, such that $\mathcal{P} \subset \mathcal{D}''_{R}$. However, $\text{iOFR}_{S}$ searches through the full space $\mathcal{D}''$ instead of $\mathcal{D}''_{R}$. Therefore, this technique converges the $\text{iOFR}_{S}$ faster to an optimal model compared to RCT method 2.

RCT methods aim to speed up $\text{iOFR}{S}$ by reducing computation time. Using a smaller candidate set $\mathcal{D}''_{R}$  reduces the computational time of the OFR within $\text{iOFR}_{S}$, and fewer redundant terms in $\mathcal{P}$ lead to quicker convergence by reducing the number of orthogonalization paths [@guo2015a]. Among the methods, RCT 3 is most effective, followed by 1, 4, and 2. However, methods 1 and 3 may miss important terms, especially in noisy or complex systems, leading to sub-optimal models. RCT methods also add overhead; therefore, if $\mathcal{D}''$ is already small, using $\text{iOFR}_{S}$ without RCT may be more efficient. The figure below presents Algorithm \autoref{fig:alg} as a flowchart. The next section includes examples from the NonSysId package.

NARX models can be analysed in the frequency domain using Nonlinear Output Frequency Response Functions (NOFRFs) [@Lang2005], which extend classical frequency response analysis to nonlinear systems (Chapter 6, [@billings2013a]). The NOFRF concept is an essential tool for system identification, describing how input frequencies interact nonlinearly to generate output frequencies that are harmonics and intermodulation effects. This facilitates a detailed understanding of how nonlinearities affect input-output dynamics [@Lang2005;@BAYMA2018]. NOFRFs can be evaluated using various methods [@Gunawardena2018;@ZHU2022], providing enhanced insights into the frequency-domain behaviour of complex nonlinear systems. Consequently, NOFRFs enhance the utility of NARX models by offering a comprehensive framework for analysing and interpreting nonlinear system [@Zhu2021].

# Examples

This section presents two examples showcasing the use of the NonSysID package, which implements $\text{iOFR}_{S}$ with PRESS-statistic-based term selection. The first example utilises synthetic data generated from a NARX model, while the second focuses on real data obtained from an electro-mechanical system.

## Synthetic data example

The following example demonstrates how to identify a NARX model using the `NonSysId` package. In this example, we consider a NARX model of a DC motor (\autoref{eq:NARX_eg}) as described in [@Lacerda2017].
\begin{multline} \label{eq:NARX_eg}
    y(t) = 1.7813y(t-1) - 0.7962y(t-2) + 0.0339u(t-1) + 0.0338u(t-2)\\
    - 0.1597y(t-1)u(t-1) - 0.1396y(t-1)u(t-2)\\
    + 0.1297y(t-2)u(t-1) + 0.1086y(t-2)u(t-2) + 0.0085y(t-2)^2
\end{multline}
In \autoref{eq:NARX_eg}, $y(t)$ is the output and $u(t)$ is the input to the system at the time sample $t$. The NARX model is separately excited using two inputs: (a) White noise, where $u(t)\sim\mathcal{N}(0,1)$, and (b) a multi-tone sinusoidal wave defined as $u(t) = 0.2\big( 4\sin{(\pi t)} + 1.2\sin{(4\pi t)} + 1.5\sin{(8\pi t)} + 0.5\sin{(6\pi t)} \big)$. The model was simulated for 1000 time samples. Identification results for both input cases are presented below. Matlab scripts for this example are available in the code repository, along with documentation in the code repository provides a straightforward guide for using $\text{iOFR}_{S}$ in the `NonSysId` package.

\autoref{fig:narx_eg_a_io} and \autoref{fig:narx_eg_b_io} depict the training and testing data alongside the model simulated output for the inputs (a) and (b), respectively. The term `testing data` is used to refer to data not explicitly included during training, as the model is already validated through leave-one-out cross-validation during the identification/training process (see sub-section `PRESS-statistic-based term selection`).

![**Model identification results under input (a)**. The model simulation output $\hat{y}(t)$ is shown against the actual output $y(t)$ of the system given in \autoref{eq:NARX_eg}. The input $u(t)$ is a Gaussian white noise signal. Only the first 60 samples are used for identifying/training the model using $\text{iOFR}_{S}$ in the `NonSysId` package. The error variance (residual variance) in this case is $1.6018e^{-25}$.\label{fig:narx_eg_a_io}](Figures/ex_dc_motor_a_60.svg){width="80%"}

\autoref{tbl:inpt_a_param} and \autoref{tbl:inpt_b_param} present the identified terms and parameter values of the corresponding NARX models under inputs (a) and (b), respectively. These tables also include the mean squared PRESS error and the ERR metrics for each term. The values of these metrics depend on the order in which the terms were added to the model during the forward selection procedure, determined by the orthogonalization path taken by the OFR algorithm (sub-section `Iterative OFR`). The mean squared PRESS error reflects the one-step-ahead leave-one-out cross-validation error after the term is added to the model. Sorting \autoref{tbl:inpt_a_param} and \autoref{tbl:inpt_b_param} in descending order of the mean squared PRESS error reveals the sequence of the terms added. For example, in `Table 1`, the term $u(t-1)$ was added first (indicating the orthogonalization path starts with this term) followed by $y(t-1)$, $y(t-2)$, and so on. The ERR represents the proportion of the actual output variance (variance of $y(t)$) explained by each corresponding term.

| Model term        |  Mean squared PRESS error    | ERR                     | Parameters/Coefficients |
|-------------------|------------------------------|-------------------------|-------------------------|
| $y(t-1)$          | $1.342 \times 10^{-3}$       | $0.95001$               | $\ \ 1.7813$            |
| $y(t-2)$          | $1.6759 \times 10^{-4}$      | $2.255 \times 10^{-3}$  | $-0.7962$               |
| $u(t-1)$          | $0.47871$                    | $4.7434 \times 10^{-2}$ | $\ \ 0.0339$            |
| $u(t-2)$          | $6.8123 \times 10^{-5}$      | $1.8925 \times 10^{-4}$ | $\ \ 0.0338$            |
| $y(t-1)u(t-1)$    | $2.2653 \times 10^{-5}$      | $3.6489 \times 10^{-5}$ | $-0.1597$               |
| $y(t-1)u(t-2)$    | $6.1439 \times 10^{-5}$      | $1.9004e \times 10^{-5}$| $-0.1396$               |
| $y(t-2)y(t-2)$    | $3.1515 \times 10^{-30}$     | $5.3837e \times 10^{-7}$| $\ \ 0.0085$            |
| $y(t-2)u(t-1)$    | $3.7241 \times 10^{-7}$      | $2.9966e \times 10^{-5}$| $\ \ 0.1297$            |
| $y(t-2)u(t-2)$    | $4.6109 \times 10^{-5}$      | $2.8901e \times 10^{-5}$| $\ \ 0.1086$            |
: The model identified when \autoref{eq:NARX_eg} is excited with input (a), white noise \label{tbl:inpt_a_param}

![**Model identification results under input (b)**. The model simulated output, $\hat{y}(t)$, is compared with the actual output, $y(t)$, as defined in \autoref{eq:NARX_eg}. The input is a multi-tone sinusoidal. In this case, the portion of $y(t)$ used for identification/training (yellow curve) is less informative compared to input (a), as fewer system dynamics are excited due to the limited frequency components in the input signal. Therefore, up to 200 samples are used for identifying the model using $\text{iOFR}_{S}$ in the `NonSysId` package. The error variance (residual variance) is $8.2178e^{-18}$. Using fewer than 200 samples results in a sub-optimal model, as insufficient data limits the ability to capture the system's dynamics effectively.\label{fig:narx_eg_b_io}](Figures/ex_dc_motor_b_200.svg){width="80%"}

| Model term        |  Mean squared PRESS error    | ERR                     | Parameters/Coefficients |
|-------------------|------------------------------|-------------------------|-------------------------|
| $y(t-1)$          | $1.2209 \times 10^{-4}$      | $0.1035$                | $1.7813$                |
| $y(t-2)$          | $7.0858 \times 10^{-7}$      | $1.7841 \times 10^{-4}$ | $-0.7962$               |
| $u(t-1)$          | $2.8085 \times 10^{-9}$      | $2.5768 \times 10^{-9}$ | $0.0339$                |
| $u(t-2)$          | $3.7183 \times 10^{-8}$      | $3.5856 \times 10^{-7}$ | $0.0338$                |
| $y(t-1)u(t-1)$    | $4.5778 \times 10^{-12}$     | $2.7792 \times 10^{-9}$ | $-0.1597$               |
| $y(t-1)u(t-2)$    | $2.9234 \times 10^{-7}$      | $6.0493 \times 10^{-7}$ | $-0.1396$               |
| $y(t-2)y(t-2)$    | $3.8123 \times 10^{-9}$      | $4.6086 \times 10^{-8}$ | $0.0085$                |
| $y(t-2)u(t-1)$    | $1.9182 \times 10^{-25}$     | $6.4198 \times 10^{-12}$| $0.1297$                |
| $y(t-2)u(t-2)$    | $7.0559 \times 10^{-2}$      | $0.89632$               | $0.1086$                |
: The model identified when \autoref{eq:NARX_eg} is excited with input (b), a multi-tone sinusoid \label{tbl:inpt_b_param}

The correlation based statistical validation tests for nonlinear models [@Billings1983] are presented in \autoref{fig:narx_eg_a_val} and \autoref{fig:narx_eg_b_val}. These validation tests are conducted on the training data (yellow region of $y(t)$ in \autoref{fig:narx_eg_a_io} and \autoref{fig:narx_eg_b_io}). From the auto-correlation function (ACF) of the residuals, it is observed that the model residuals, in both cases (a) and (b), are not entirely white noise. Additionally, in \autoref{fig:narx_eg_b_val}, the cross-correlation functions (Cross-CF) between the input $u(t)$ and the model residuals are not completely within the tolerance bounds, indicating some bias in the model. However, the variance of the model residuals are $1.6018e^{-25}$ and $8.2178e^{-18}$, respectively, for (a) and (b), compared to the training data variances of $0.069$ and $0.0581$. This shows that the bias of the identified model is minimal. As such, even though the identified terms and parameters (\autoref{tbl:inpt_a_param} and \autoref{tbl:inpt_b_param}) are similar to the actual system (\autoref{eq:NARX_eg}), the parameters do have differences considering from the 4^th^ decimal place and beyond.

![Model validation results for input (a). The red bounds indicate the tolerances the correlation function should stay within for the identified model to be unbiased.\label{fig:narx_eg_a_val}](Figures/ex_dc_motor_a_60_vald.svg){width="70%"}

![Model validation results for input (b). The red bounds indicate the tolerances the correlation function should stay within for the identified model to be unbiased.\label{fig:narx_eg_b_val}](Figures/ex_dc_motor_b_200_vald.svg){width="70%"}

## Real data example

The real data in this example is obtained from an electromechanical system described in [@Lacerda2017b]. The system comprises two 6V DC motors mechanically coupled by a shaft. One motor acts as the driver, transferring mechanical energy, while the other operates as a generator, converting the mechanical energy into electrical energy. The system input is the voltage applied to the DC motor acting as the driver. This input is a pseudo-random binary signal (PRBS) designed to excite the system over a range of dynamics. The output of the system is the rotational speed (angular velocity) of the generator motor.

![**Model identification results from the electro-mechanical system**. The model simulation output $\hat{y}(t)$ is presented against the actual output $y(t)$ of the system given in \autoref{eq:NARX_eg}. The input $u(t)$ is a PRBS. Only 250 samples are used for identifying/training the model using $\text{iOFR}_{S}$ in the `NonSysId' package.\label{fig:narx_eg_rldt_sys}](Figures/ele_mech_sysId.svg){width="100%"}

| Model term        |  Mean squared PRESS error   | ERR                     | Parameters/Coefficients |
|-------------------|-----------------------------|-------------------------|-------------------------|
| $y(t-1)$          | $8128.5$                    | $0.49526$               | $1.7844$                |
| $y(t-2)$          | $975.85$                    | $0.00028497$            | $-0.79156$              |
| $u(t-1)$          | $318.88$                    | $2.6363 \times 10^{-5}$ | $47.205$                |
| $y(t-2)u(t-1)$    | $158.23$                    | $6.211 \times 10^{-6}$  | $-0.037612$             |
| $y(t-3)u(t-1)$    | $1.2306 \times 10^{7}$      | $0.50441$               | $0.030086$              |
| $u(t-2)u(t-2)$    | $91.271$                    | $2.5147 \times 10^{-6}$ | $1.89$                  |
| $u(t-2)u(t-3)$    | $71.842$                    | $7.2261 \times 10^{-7}$ | $-0.91694$              |
: The model identified from the data generated from the system in [@Lacerda2017b] \label{tbl:narx_eg_rldt_val}

![**Model validation results for the system in [@Lacerda2017b]**. The red bounds indicate the tolerances the correlation function should stay within for the identified model to be unbiased.\label{fig:narx_eg_rldt_val}](Figures/ele_mech_sysId_vald_mpo.svg){width="100%"}

# Future Work
Currently, the `NonSysId` package is capable of identifying single-input single-output (SISO) and multi-input single-output (MISO) models. However, the correlation-based residual analysis is limited to handling only SISO models. In the future, we plan to extend the package to identify multi-input multi-output (MIMO) and enable validation for both MISO and MIMO systems. In [@CHEN2006], a local regularisation method for the OFR was introduced. This will be incorporated into $\text{iOFR}_{S}$. While the `NonSysId` package currently supports polynomial NARX models, future versions will broaden its scope to allow  $\text{iOFR}_{S}$ to be applied to a wider range of basis functions. Furthermore, an open-sourced Python version of this package is expected to be released in the future.

# Acknowledgements
RG and FH were supported by EPSRC grant [EP/X020193/1].

# References







