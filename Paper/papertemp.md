## Synthetic data example

The following example demonstrates how to identify a NARX model using the `NonSysId` package. In this example, we consider a NARX model of a DC motor (Eq. \eqref{eq:NARX_eg}) as described in [@Lacerda2017].
\begin{multline} \label{eq:NARX_eg}
    y(t) = 1.7813y(t-1) - 0.7962y(t-2) + 0.0339u(t-1) + 0.0338u(t-2)\\
    - 0.1597y(t-1)u(t-1) - 0.1396y(t-1)u(t-2)\\
    + 0.1297y(t-2)u(t-1) + 0.1086y(t-2)u(t-2) + 0.0085y(t-2)^2
\end{multline}
In Eq. \eqref{eq:NARX_eg}, $y(t)$ is the output and $u(t)$ is the input to the system at the time sample $t$. The NARX model is separately excited using two inputs: (a) White noise, where $u(t)\sim\mathcal{N}(0,1)$, and (b) a multi-tone sinusoidal wave defined as $u(t) = 0.2\big( 4\sin{(\pi t)} + 1.2\sin{(4\pi t)} + 1.5\sin{(8\pi t)} + 0.5\sin{(6\pi t)} \big)$. The model was simulated for 1000 time samples. Identification results for both input cases are presented below. Matlab scripts for this example are available in the code repository, along with documentation in the code repository provides a straightforward guide for using $\text{iOFR}_{S}$ in the `NonSysId` package.

Fig. \ref{fig:narx_eg_a_io} and \ref{fig:narx_eg_b_io} depict the training and testing data alongside the model simulated output for the inputs (a) and (b), respectively. The term `testing data` is used to refer to data not explicitly included during training, as the model is already validated through leave-one-out cross-validation during the identification/training process (see sub-section \ref{sec:PRESS}).

%----------------------------
\begin{figure}[!h]
    \centering
    \includegraphics[width=0.61\textwidth]{Figures/ex_dc_motor_a_60.eps}
    \caption{\textbf{Model identification results under input (a)}. The model simulation output $\hat{y}(t)$ is shown against the actual output $y(t)$ of the system given in Eq. \eqref{eq:NARX_eg}. The input $u(t)$ to the system is a Gaussian white noise signal $u(t)\sim\mathcal{N}(0,1)$. Only the first 60 samples are used for identifying/training the model using $\text{iOFR}_{S}$ in the `NonSysId` package. The variance of the error or model residuals in this case is $1.6018e^{-25}$}
    \label{fig:narx_eg_a_io}
\end{figure}
%----------------------------
![**Model identification results under input (a)**. The model simulation output $\hat{y}(t)$ is shown against the actual output $y(t)$ of the system given in Eq. \eqref{eq:NARX_eg}. The input $u(t)$ to the system is a Gaussian white noise signal $u(t)\sim\mathcal{N}(0,1)$. Only the first 60 samples are used for identifying/training the model using $\text{iOFR}_{S}$ in the `NonSysId` package. The variance of the error or model residuals in this case is $1.6018e^{-25}$.\label{fig:flowcharts}](Figures/ex_dc_motor_a_60.eps)

%----------------------------
\begin{table}[!h]
    \normalsize
	\centering
	\caption{The model identified when Eq. \eqref{eq:NARX_eg} is excited with input (a), white noise}
	\vspace{1ex}
	\begin{tabular}{|c|c|c|c|}
		\hline
		Model term & \specialcell{Mean squared\\PRESS error} & ERR & Parameters/Coefficients\\
		\hline
        $y(t-1)$       & $1.342 \times 10^{-3}$   & $0.95001$                & \ \ $1.7813$ \\
        $y(t-2)$       & $1.6759 \times 10^{-4}$  & $2.255  \times 10^{-3}$  & $-0.7962$ \\
        $u(t-1)$       & $0.47871$                & $4.7434 \times 10^{-2}$  & \ \ $0.0339$ \\
        $u(t-2)$       & $6.8123 \times 10^{-5}$  & $1.8925 \times 10^{-4}$  & \ \ $0.0338$ \\
        $y(t-1)u(t-1)$ & $2.2653 \times 10^{-5}$  & $3.6489 \times 10^{-5}$  & $-0.1597$ \\
        $y(t-1)u(t-2)$ & $6.1439 \times 10^{-5}$  & $1.9004e \times 10^{-5}$ & $-0.1396$ \\
        $y(t-2)y(t-2)$ & $3.1515 \times 10^{-30}$ & $5.3837e \times 10^{-7}$ & \ \ $0.0085$ \\
        $y(t-2)u(t-1)$ & $3.7241 \times 10^{-7}$  & $2.9966e \times 10^{-5}$ & \ \ $0.1297$ \\
        $y(t-2)u(t-2)$ & $4.6109 \times 10^{-5}$  & $2.8901e \times 10^{-5}$ & \ \ $0.1086$ \\
    	\hline
	\end{tabular}%
	\label{tbl:inpt_a_param}%
\end{table}%
%----------------------------

Tables \ref{tbl:inpt_a_param} and \ref{tbl:inpt_b_param} present the identified terms and parameter values of the corresponding NARX models under inputs (a) and (b), respectively. These tables also include the mean squared PRESS error and the ERR metrics for each term. The values of these metrics depend on the order in which the terms were added to the model during the forward selection procedure, determined by the orthogonalization path taken by the OFR algorithm (sub-section \ref{sec:iOFR}). The mean squared PRESS error reflects the one-step-ahead leave-one-out cross-validation error after the term is added to the model. Sorting tables \ref{tbl:inpt_a_param} and \ref{tbl:inpt_b_param} in descending order of the mean squared PRESS error reveals the sequence of the terms added. For example, in table \ref{tbl:inpt_a_param}, the term $u(t-1)$ was added first (indicating the orthogonalization path starts with this term) followed by $y(t-1)$, $y(t-2)$, and so on. The ERR represents the proportion of the actual output variance (variance of $y(t)$) explained by each corresponding term.
%----------------------------
\begin{figure}[!h]
    \centering
    \includegraphics[width=0.61\textwidth]{Figures/ex_dc_motor_b_200.eps}
    \caption{\textbf{Model identification results under input (b)}. The model simulated output, $\hat{y}(t)$, is compared with the actual output, $y(t)$, as defined in Eq. \eqref{eq:NARX_eg}. The input $u(t)$ to the system is a multi-tone sinusoidal signal given by $u(t) = 0.2\big( 4\sin{(\pi t)} + 1.2\sin{(4\pi t)} + 1.5\sin{(8\pi t)} + 0.5\sin{(6\pi t)} \big)$. In this case, the portion of $y(t)$ used for identification/training (yellow curve) is less informative compared to input (a), as fewer system dynamics are excited due to the limited frequency components in the input signal. Therefore, up to 200 samples are used for identifying the model using $\text{iOFR}_{S}$ in the `NonSysId` package. The variance of the error or model residuals in this scenario is $8.2178e^{-18}$. Using fewer than 200 samples results a sub-optimal model, as insufficient data limits the ability to capture the system's dynamics effectively.}
    \label{fig:narx_eg_b_io}
\end{figure}
%----------------------------
%----------------------------
\begin{table}[!h]
    \normalsize
	\centering
	\caption{The model identified when Eq. \eqref{eq:NARX_eg} is excited with input (b), a multi-tone sinusoid}
	\vspace{1ex}
	\begin{tabular}{|c|c|c|c|}
		\hline
		Model term & \specialcell{Mean squared\\PRESS error} & ERR & Parameters/Coefficients\\
		\hline
        $y(t-1)$       & $1.2209 \times 10^{-4}$    & $0.1035$                  & \ \ $1.7813$  \\
        $y(t-2)$       & $7.0858 \times 10^{-7}$    & $1.7841  \times 10^{-4}$  & $-0.7962$ \\
        $u(t-1)$       & $2.8085 \times 10^{-9}$    & $2.5768 \times 10^{-9}$   & \ \ $0.0339$  \\
        $u(t-2)$       & $3.7183 \times 10^{-8}$    & $3.5856 \times 10^{-7}$   & \ \ $0.0338$  \\
        $y(t-1)u(t-1)$ & $4.5778 \times 10^{-12}$   & $2.7792 \times 10^{-9}$   & $-0.1597$ \\
        $y(t-1)u(t-2)$ & $2.9234 \times 10^{-7}$    & $6.0493 \times 10^{-7}$   & $-0.1396$ \\
        $y(t-2)y(t-2)$ & $3.8123 \times 10^{-9}$    & $4.6086 \times 10^{-8}$   & \ \ $0.0085$  \\
        $y(t-2)u(t-1)$ & $1.9182 \times 10^{-25}$   & $6.4198 \times 10^{-12}$  & \ \ $0.1297$  \\
        $y(t-2)u(t-2)$ & $7.0559 \times 10^{-2}$    & $0.89632$                 & \ \ $0.1086$  \\
    	\hline
	\end{tabular}%
	\label{tbl:inpt_b_param}%
\end{table}%
%----------------------------
%----------------------------
\begin{figure}[!htb]
    \centering
    \includegraphics[width=0.66\textwidth]{Figures/ex_dc_motor_a_60_vald.eps}
    \caption{Model validation results for input (a). The red bounds indicate the tolerances the correlation function should stay within for the identified model to be unbiased.}
    \label{fig:narx_eg_a_val}
\end{figure}
%----------------------------
%----------------------------
\begin{figure}[!htb]
    \centering
    \includegraphics[width=0.66\textwidth]{Figures/ex_dc_motor_b_200_vald.eps}
    \caption{Model validation results for input (b). The red bounds indicate the tolerances the correlation function should stay within for the identified model to be unbiased.}
    \label{fig:narx_eg_b_val}
\end{figure}
%----------------------------

The correlation based statistical validation tests for nonlinear models [@Billings1983] are presented in Fig. \ref{fig:narx_eg_a_val} and \ref{fig:narx_eg_b_val}. These validation tests are conducted on the training data (yellow region of $y(t)$ in Fig. \ref{fig:narx_eg_a_io} and \ref{fig:narx_eg_b_io}). From the auto-correlation function (ACF) of the residuals, it is observed that the model residuals, in both cases (a) and (b), are not entirely white noise. Additionally, in Fig. \ref{fig:narx_eg_b_val}, the cross-correlation functions (Cross-CF) between the input $u(t)$ and the model residuals are not completely within the tolerance bounds, indicating some bias in the model. However, the variance of the model residuals are $1.6018e^{-25}$ and $8.2178e^{-18}$, respectively, for (a) and (b), compared to the training data variances of $0.069$ and $0.0581$. This shows that the bias of the identified model is minimal. As such, even though the identified terms and parameters (Tables \ref{tbl:inpt_a_param} and \ref{tbl:inpt_b_param}) are similar to the actual system (Eq. \eqref{eq:NARX_eg}), the parameters do have differences considering from the 4\textsuperscript{th} decimal place and beyond.
